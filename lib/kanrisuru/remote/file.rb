# frozen_string_literal: true

require 'date'

module Kanrisuru
  module Remote
    class File
      include Enumerable

      WRITE_LINE_COUNT = 5_000
      READ_FILE_SIZE = 3_000_000

      attr_reader :mode, :blocks, :size, :type, :gid, :group, :uid, :user, :inode, :last_access, :last_modified,
                  :last_changed, :lines, :words, :chars, :path

      def initialize(path, host, backup = nil)
        @path = path
        @host = host
        @backup = backup

        @file_lines = []

        reload! if exists?
      end

      def expand_path
        return '' unless exists?

        result = @host.realpath(@path)
        result.success? ?	result.path : ''
      end

      def exists?
        @host.inode?(@path)
      end

      def file?
        @host.file?(@path)
      end

      def [](index)
        if chunk_read_file? && index < @lines
          chunk_read_line_by_index(index)
        elsif index < @lines
          @file_lines[index]
        else
          raise ArgumentError, "Out of bounds index access for #{index}"
        end
      end

      def dir?
        @host.dir?(@path)
      end

      def zero?
        @host.empty_file?(@path)
      end

      def chmod(mode)
        result = @host.chmod(@path, mode)
        update_file_attributes(result) if result.success?
      end

      def chown(owner, group)
        result = @host.chown(@path, owner: owner, group: group)
        update_file_attributes(result) if result.success?
      end

      def writeable?
        return @writeable if [true, false].include?(@writeable)

        if !file? && !zero?
          @writeable = false
          return false
        end

        current_user = @host.remote_user
        result = @host.get_user(current_user)

        raise 'Invalid result' unless result.success?

        groups = result.groups.map(&:name)

        @writeable = @mode.other.write? ||
                     (@mode.group.write? && groups.include?(@group)) ||
                     (@mode.owner.write? && @user == current_user)
      end

      def find_and_replace_value(regex, value)
        new_lines = []

        each do |existing_line|
          new_lines << if regex.match(existing_line)
                         existing_line.gsub(regex, value)
                       else
                         existing_line
                       end
        end

        write_lines_to_file(new_lines, 'write')
      end

      def find_and_replace_line(regex, new_line)
        new_lines = []

        each do |existing_line|
          new_lines << if regex.match(existing_line)
                         new_line
                       else
                         existing_line
                       end
        end

        write_lines_to_file(new_lines, 'write')
      end

      def find_and_append(regex, new_line)
        new_lines = []

        each do |existing_line|
          new_lines << existing_line
          new_lines << new_line if regex.match(existing_line)
        end

        write_lines_to_file(new_lines, 'write')
      end

      def find_and_prepend(regex, new_line)
        new_lines = []

        each do |existing_line|
          new_lines << new_line if regex.match(existing_line)
          new_lines << existing_line
        end

        write_lines_to_file(new_lines, 'write')
      end

      def find_and_remove(regex)
        new_lines = []

        each do |existing_line|
          new_lines << existing_line unless regex.match(existing_line)
        end

        write_lines_to_file(new_lines, 'write')
      end

      def write(&block)
        return unless writeable?

        new_lines = []
        block.call(new_lines)

        backup_file if should_backup?
        write_lines_to_file(new_lines, 'write')
      end

      def append(&block)
        return unless writeable?

        new_lines = []
        block.call(new_lines)

        backup_file if should_backup?
        write_lines_to_file(new_lines, 'append')
      end

      def prepend(&block)
        return unless writeable?

        new_lines = []
        block.call(new_lines)

        backup_file if should_backup?

        ## If large file, use tmp file to prepend to
        if chunk_read_file?
          tmp_file = "/tmp/kanrisuru-tempfile-#{Time.now.strftime('%Y-%m-%d-%H-%M-%S-%L')}"

          @host.echo(new_lines.join('\\n'), new_file: tmp_file, backslash: true, mode: 'write')
          @host.cat(@path, new_file: tmp_file, mode: 'append')
          @host.cp(tmp_file, @path)

          @host.rm(tmp_file)
          reload!
        else
          all_lines = new_lines + @file_lines
          write_lines_to_file(all_lines, 'write')
        end
      end

      def rename(new_path)
        # @host.mv()
      end

      def touch
        result = @host.touch(@path)
        update_file_attributes(result[0]) if result.success?
      end

      def delete
        result = @host.unlink(@path)

        init_file_attirbutes if result.success?

        result.success?
      end

      def each(&block)
        if chunk_read_file?
          each_chunk(&block)
        else
          @file_lines.each { |line| block.call(line) }
        end
      end

      def reload!
        @writeable = nil
        @file_lines = []

        wc_file
        stat_file
        read
      end

      private

      def should_backup?
        Kanrisuru::Util.present?(@backup)
      end

      def backup_file
        result = @host.cp(@path, @backup)
        raise "Backup of #{@path} failed" if result.failure?
      end

      def each_chunk(&block)
        chunk_size = @lines >> 1
        index = 1

        loop do
          result = @host.read_file_chunk(@path, index, index + chunk_size - 1)
          break if result.failure?

          lines = result.data
          lines.each { |line| block.call(line) }

          break if index >= @lines

          index += chunk_size
        end
      end

      def read
        return if chunk_read_file?

        result = @host.cat(@path)
        raise 'Error reading remote file' if result.failure?

        @file_lines = result.data
      end

      def write_lines_to_file(lines, mode)
        if lines.length < WRITE_LINE_COUNT
          write_to_file(lines, mode)
        else
          chunk_write_to_file(lines, mode)
        end
      end

      def write_to_file(lines, mode)
        result = @host.echo(lines.join('\\n'), new_file: @path, backslash: true, mode: mode)

        reload! if result.success?
      end

      def chunk_write_to_file(lines, mode)
        ## Clear initial file to write new data
        if mode == 'write'
          @host.unlink(@path)
          @host.touch(@path)
        end

        lines.each_slice(WRITE_LINE_COUNT) do |lines_slice|
          result = @host.echo(lines_slice.join('\\n'), new_file: @path, backslash: true, mode: 'append')
          raise 'Error appending lines to file' if result.failure?
        end

        reload!
      end

      def chunk_read_file?
        @size >= READ_FILE_SIZE
      end

      def chunk_read_line_by_index(index)
        result = @host.read_file_chunk(@path, index + 1, index + 1)
        result.success? ? result[0] : nil
      end

      def wc_file
        result = @host.wc(@path)

        return if result.failure?

        @lines = result.lines
        @words = result.words
        @chars = result.characters
      end

      def stat_file
        result = @host.stat(@path)

        update_file_attributes(result) if result.success?
      end

      def update_file_attributes(result)
        @mode = result.mode
        @blocks = result.blocks
        @size = result.fsize
        @type = result.file_type
        @gid = result.gid
        @group = result.group
        @uid = result.uid
        @user = result.user
        @inode = result.inode
        @last_access = result.last_access
        @last_modified = result.last_modified
        @last_changed = result.last_changed
      end

      def init_file_attirbutes
        @writeable = nil
        @mode = nil
        @blocks = nil
        @size = nil
        @type = nil
        @gid = nil
        @group = nil
        @uid = nil
        @user = nil
        @inode = nil
        @last_access = nil
        @last_modified = nil
        @last_changed = nil

        @lines = nil
        @words = nil
        @chars = nil
      end
    end
  end
end
