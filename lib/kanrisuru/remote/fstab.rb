# frozen_string_literal: true

module Kanrisuru
  module Remote
    class Fstab
      include Enumerable

      def initialize(host, path = '/etc/fstab')
        @host = host
        @path = path
        @file = nil
        @backup = nil

        init_from_os
      end

      def [](device)
        get_entry(device)
      end

      def get_entry(device)
        result = @entries[device]

        return result[:entry] if result

        result = nil

        ## Lookup by uuid or label
        @entries.each do |_, entry|
          result = entry[:entry] if !@result && (entry[:entry].uuid == device || entry[:entry].label == device)
        end

        result
      end

      def <<(entry)
        append(entry)
      end

      def append(entry)
        if entry.instance_of?(Kanrisuru::Remote::Fstab::Entry)
          return if @entries.key?(entry.device)
        elsif entry.instance_of?(String)
          entry = Kanrisuru::Remote::Fstab::Entry.new(host: @host, line: entry)
          return if @entries.key?(entry.device)
        else
          raise ArgumentError, 'Invalid entry type'
        end

        @entries[entry.device] = {
          entry: entry,
          new: true
        }

        nil
      end

      def find_device(device); end

      def each(&block)
        @entries.each do |_, entry|
          block.call(entry[:entry])
        end
      end

      ## Only append new entries to file
      def append_file!
        @file.append do |f|
          @entries.each do |_, entry|
            f << entry[:entry].to_s if entry[:new]
          end
        end

        reload!
      end

      ## Rewrites entire fstab file with new and old entries
      def write_file!
        @file.write do |f|
          @entries.each do |_, entry|
            f << entry[:entry].to_s
          end
        end

        reload!
      end

      def to_s
        lines = []
        @entries.each do |_, entry|
          lines << entry[:entry].to_s
        end

        lines.join("\n")
      end

      def reload!
        init_from_os
      end

      def inspect
        format('#<Kanrisuru::Remote::Fstab:0x%<object_id>s @path=%<path>s @entries=%<entries>s>',
               object_id: object_id, path: @path, entries: @entries)
      end

      private

      def init_from_os
        @entries = {}

        raise 'Not implemented' unless @host.os && @host.os.kernel == 'Linux'

        initialize_linux
      end

      def initialize_linux
        if @file
          @file.reload!
        else
          @file = @host.file(@path)
        end

        raise ArgumentError, 'Invalid file' if !@file.exists? || !@file.file?

        @file.each do |line|
          next if line.strip.chomp.empty?
          next if line =~ /\s*#/

          entry = Fstab::Entry.new(host: @host, line: line)
          @entries[entry.device] = {
            entry: entry,
            new: false
          }
        end
      end

      class Entry
        attr_reader :device, :uuid, :invalid, :label, :type, :opts, :freq, :passno
        attr_accessor :mount_point

        def initialize(opts = {})
          @host = opts[:host]
          @line = opts[:line]

          @default = nil

          @device = opts[:device] || nil
          @opts = opts[:opts] || nil
          @label = opts[:label] || nil
          @uuid = opts[:uuid] || nil
          @mount_point = opts[:mount_point] || nil
          @type = opts[:type] || nil
          @freq = opts[:freq] || nil
          @passno = opts[:passno] || nil

          @changed = false

          @ucount = 0
          @special = false
          @invalid = false

          if Kanrisuru::Util.present?(@line) && @line.instance_of?(String)
            parse_line!
          elsif Kanrisuru::Util.present?(@opts) && @opts.instance_of?(String) || @opts.instance_of?(Hash)
            @opts = Kanrisuru::Remote::Fstab::Options.new(@type, @opts)
          end
        end

        def inspect
          str = '#<Kanrisuru::Remote::Fstab::Entry:0x%<object_id>s ' \
            '@line=%<line>s @device=%<device>s @label=%<label>s' \
            '@uuid=%<uuid>s @freq=%<freq>s @pasno=%<passno>s' \
            '@opts=%<opts>s}>'

          format(
            str,
            object_id: object_id,
            line: @line,
            device: @device,
            label: @label,
            uuid: @uuid,
            freq: @freq,
            passno: @passno,
            opts: @opts.inspect
          )
        end

        def valid?
          !@invalid
        end

        def to_s(override = nil)
          mode = override || @default

          case mode
          when 'uuid'
            "UUID=#{@uuid} #{@mount_point} #{@type} #{@opts} #{@freq} #{@passno}"
          when 'label'
            "LABEL=#{@label} #{@mount_point} #{@type} #{@opts} #{@freq} #{@passno}"
          else
            "#{@device} #{@mount_point} #{@type} #{@opts} #{@freq} #{@passno}"
          end
        end

        private

        def parse_line!
          fsline, mp, @type, opts, freq, passno = @line.split

          @mount_point = mp
          @freq = freq || '0'
          @passno = passno || '0'

          @opts = Fstab::Options.new(@type, opts)

          case @line
          when /^\s*LABEL=/
            @default = 'label'
            parse_label(fsline)
          when /^\s*UUID=/
            @default = 'uuid'
            parse_uuid(fsline)
          when %r{^\s*/dev}
            @default = 'dev'
            parse_dev(fsline)
          else
            # TODO: somewhat risky to assume that everything else
            # can be considered a special device, but validating this
            # is really tricky.
            @special = true
            @device = fsline
          end

          # Fstab entries not matching real devices have device unknown
          @invalid = (@line.split.count != 6) # invalid entry if < 6 columns

          if (@uuid.nil? && @label.nil? && !@special) ||
             @device =~ /^unknown_/ ||
             (!@host.inode?(@device) && !@special)
            @invalid = true
            @ucount += 1
          end

          @invalid = true unless @freq =~ /0|1|2/ && @passno =~ /0|1|2/
        end

        def parse_label(fsline)
          @label = fsline.split('=').last.strip.chomp
          path = @host.realpath("/dev/disk/by-label/#{@label}").path

          @device = begin
            "/dev/#{path.split('/').last}"
          rescue StandardError
            "unknown_#{@ucount}"
          end

          result = @host.blkid(device: @device)
          @uuid = result.success? ? result.uuid : nil
        end

        def parse_uuid(fsline)
          @uuid = fsline.split('=').last.strip.chomp
          path = @host.realpath("/dev/disk/by-uuid/#{uuid}").path

          @device = begin
            "/dev/#{path.split('/').last}"
          rescue StandardError
            "unknown_#{@ucount}"
          end

          result = @host.blkid(device: @device)
          @label = result.success? ? result.label : nil
        end

        def parse_dev(fsline)
          @device = fsline
          result = @host.blkid(device: @device)

          @label = result.success? ? result.label : nil
          @uuid = result.success? ? result.uuid : nil
        end
      end

      class Options
        def initialize(type, opts)
          @type = type
          @valid = false

          if opts.instance_of?(String)
            @opts = parse_opts(opts)
          elsif opts.instance_of?(Hash)
            @opts = opts.transform_keys(&:to_s)
          else
            raise ArgumentError, 'Invalid option type'
          end

          validate_opts!
        end

        def inspect
          format('<Kanrisuru::Remote::Fstab::Options:0x%<object_id>s @opts=%<opts>s @type=%<type>s>',
                 object_id: object_id, opts: @opts, type: @type)
        end

        def [](option)
          @opts[option]
        end

        def []=(option, value)
          option = option.to_s

          unless Kanrisuru::Remote::Fstab::Options.option_exists?(option, @type)
            raise ArgumentError,
                  "Invalid option: #{option} for #{@type} file system."
          end

          unless Kanrisuru::Remote::Fstab::Options.valid_option?(option, value, @type)
            raise ArgumentError,
                  "Invalid option value: #{value} for #{option} on #{@type} file system."
          end

          @opts[option] = value
        end

        def to_s
          string = ''
          opts_length = @opts.length

          @opts.each_with_index do |(key, value), index|
            append_comma = true

            if value == true
              string += key.to_s
            elsif value.instance_of?(String) || value.instance_of?(Integer) || value.instance_of?(Float)
              string += "#{key}=#{value}"
            else
              append_comma = false
            end

            string += ',' if append_comma && index < opts_length - 1
          end

          string
        end

        def to_h
          @opts
        end

        def self.option_exists?(value, type = nil)
          value = value.to_sym
          type = type ? type.to_sym : nil

          common = Kanrisuru::Util::FsMountOpts[:common]
          fs_opts = Kanrisuru::Util::FsMountOpts[type]

          common.key?(value) ||
            fs_opts&.key?(value)
        end

        def self.valid_option?(value, field, type = nil)
          value = value.to_sym
          type = type ? type.to_sym : nil

          common = Kanrisuru::Util::FsMountOpts[:common]
          fs_opts = Kanrisuru::Util::FsMountOpts[type]

          if common.key?(value)
            case common[value]
            when 'boolean'
              [true, false].include?(field)
            when 'value'
              field.instance_of?(String) || field.instance_of?(Float) || field.instance_of?(Integer)
            else
              false
            end
          elsif fs_opts&.key?(value)
            case fs_opts[value]
            when 'boolean'
              [true, false].include?(field)
            when 'value'
              field.instance_of?(String) || field.instance_of?(Float) || field.instance_of?(Integer)
            else
              false
            end
          else
            raise ArgumentError, 'Invalid option'
          end
        end

        private

        def validate_opts!
          @opts.each do |key, value|
            unless Kanrisuru::Remote::Fstab::Options.valid_option?(key, value, @type)
              raise ArgumentError, "Invalid option: #{key} for #{@type}"
            end
          end

          @valid = true
        end

        def parse_opts(string)
          opts = {}

          options = string.split(',')
          options.each do |option|
            if option.include?('=')
              opt, value = option.split('=')
              opts[opt] = value
            else
              opts[option] = true
            end
          end

          opts
        end
      end
    end
  end
end
