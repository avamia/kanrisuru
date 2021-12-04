# frozen_string_literal: true

require 'date'

module Kanrisuru
  module Core
    module File
      extend OsPackage::Define

      os_define :linux, :touch
      os_define :linux, :cp
      os_define :linux, :copy
      os_define :linux, :mkdir
      os_define :linux, :mv
      os_define :linux, :move

      os_define :linux, :link
      os_define :linux, :symlink
      os_define :linux, :ln
      os_define :linux, :ln_s

      os_define :linux, :chmod
      os_define :linux, :chown

      os_define :linux, :unlink
      os_define :linux, :rm
      os_define :linux, :rmdir

      os_define :linux, :wc

      FileCount = Struct.new(:lines, :words, :characters)

      def cp(source, dest, opts = {})
        backup = opts[:backup]
        command = Kanrisuru::Command.new('cp')

        command.append_flag('-R', opts[:recursive])
        command.append_flag('-x', opts[:one_file_system])
        command.append_flag('-u', opts[:update])
        command.append_flag('-L', opts[:follow])
        command.append_flag('-n', opts[:no_clobber])
        command.append_flag('--strip-trailing-slashes', opts[:strip_trailing_slashes])

        if backup.instance_of?(TrueClass)
          command.append_flag('-b')
        elsif Kanrisuru::Util.present?(backup)
          raise ArgumentError, 'invalid backup control value' unless backup_control_valid?(backup)

          command << "--backup=#{backup}"
        end

        if opts[:preserve].instance_of?(TrueClass)
          command.append_flag('-p')
        elsif Kanrisuru::Util.present?(opts[:preserve])
          preserve =
            (opts[:preserve].join(',') if opts[:preserve].instance_of?(Array))

          command << "--preserve=#{preserve}"
        end

        if opts[:no_target_directory]
          command.append_flag('-T')
          command << source
          command << dest
        elsif opts[:target_directory]
          command.append_arg('-t', dest)

          source = [source] if source.instance_of?(String)
          command << source.join(' ')
        else
          source = [source] if source.instance_of?(String)
          command << source.join(' ')
          command << dest
        end

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def copy(source, dest, opts = {})
        cp(source, dest, opts)
      end

      def mv(source, dest, opts = {})
        backup = opts[:backup]
        command = Kanrisuru::Command.new('mv')

        command.append_flag('--strip-trailing-slashes', opts[:strip_trailing_slashes])

        if opts[:force]
          command.append_flag('-f')
        elsif opts[:no_clobber]
          command.append_flag('-n')
        end

        if backup.instance_of?(TrueClass)
          command.append_flag('-b')
        elsif Kanrisuru::Util.present?(backup)
          raise ArgumentError, 'invalid backup control value' unless backup_control_valid?(backup)

          command << "--backup=#{backup}"
        end

        if opts[:no_target_directory]
          command.append_flag('-T')
          command << source
          command << dest
        elsif opts[:target_directory]
          command.append_arg('-t', dest)

          source = source.instance_of?(String) ? [source] : source
          command << source.join(' ')
        else
          source = source.instance_of?(String) ? [source] : source

          command << source.join(' ')
          command << dest
        end

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def move(source, dest, opts = {})
        mv(source, dest, opts)
      end

      def link(src, dest, opts = {})
        ln(src, dest, opts)
      end

      def symlink(src, dest, opts = {})
        ln_s(src, dest, opts)
      end

      def ln(src, dest, opts = {})
        ## Can't hardlink dirs
        return false if dir?(src)

        command = Kanrisuru::Command.new("ln #{src} #{dest}")
        command.append_flag('-f', opts[:force])

        execute_shell(command)

        Kanrisuru::Result.new(command) do
          stat(dest).data
        end
      end

      def ln_s(src, dest, opts = {})
        return if src == dest

        ## Use absolute path for source
        real_src = realpath(src).path

        ## Not valid if no real path, not an existing inode, or root
        raise ArgumentError, 'Invalid path' if Kanrisuru::Util.blank?(real_src) || !inode?(real_src) || real_src == '/'

        dest_is_dir = dir?(dest)

        ## Don't symlink inside an already existing symlink
        return if symlink?(dest) && dest_is_dir

        real_dest =
          if dest_is_dir
            ## Use real path for destination
            realpath(dest).path
          else
            ## Use standard path
            dest
          end

        return unless real_dest

        command = Kanrisuru::Command.new("ln -s #{real_src} #{real_dest}")
        command.append_flag('-f', opts[:force])

        execute_shell(command)

        Kanrisuru::Result.new(command) do
          stat(real_dest).data
        end
      end

      def unlink(path)
        command = Kanrisuru::Command.new("unlink #{path}")
        execute_shell(command)
        Kanrisuru::Result.new(command)
      end

      def rm(paths, opts = {})
        paths = [paths] if paths.instance_of?(String)

        paths.each do |path|
          raise ArgumentError, "Can't delete root path" if path == '/' || realpath(path).path == '/'
        end

        command = Kanrisuru::Command.new("rm #{paths.join(' ')} --preserve-root")
        command.append_flag('-f', opts[:force])
        command.append_flag('-r', opts[:recursive])

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def rmdir(paths, opts = {})
        paths = [paths] if paths.instance_of?(String)
        paths.each do |path|
          raise ArgumentError, "Can't delete root path" if path == '/' || realpath(path).path == '/'
        end

        command = Kanrisuru::Command.new("rmdir #{paths.join(' ')}")
        command.append_flag('--ignore-fail-on-non-empty', opts[:silent])
        command.append_flag('--parents', opts[:parents])

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def mkdir(path, opts = {})
        owner     = opts[:owner]
        group     = opts[:group]
        recursive = opts[:recursive]

        command = Kanrisuru::Command.new("mkdir #{path}")
        command.append_flag('-p', opts[:silent])

        if Kanrisuru::Util.present?(opts[:mode])
          mode = opts[:mode]
          if mode.instance_of?(Kanrisuru::Mode)
            mode = mode.numeric
          elsif mode.instance_of?(String) && (mode.include?(',') || /[=+-]/.match(mode))
            mode = Kanrisuru::Mode.new(mode).numeric
          end

          command.append_arg('-m', mode)
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do
          if Kanrisuru::Util.present?(owner) || Kanrisuru::Util.present?(group)
            chown(path, owner: owner, group: group, recursive: recursive)
          end

          stat(path).data
        end
      end

      def touch(paths, opts = {})
        date = opts[:date]

        paths = [paths] if paths.instance_of?(String)
        command = Kanrisuru::Command.new("touch #{paths.join(' ')}")

        command.append_flag('-a', opts[:atime])
        command.append_flag('-m', opts[:mtime])
        command.append_flag('-c', opts[:nofiles])

        if Kanrisuru::Util.present?(date)
          date = Date.parse(date) if date.instance_of?(String)
          command.append_arg('-d', date)
        end

        command.append_arg('-r', opts[:reference])

        execute_shell(command)

        Kanrisuru::Result.new(command) do
          paths.map do |path|
            stat(path).data
          end
        end
      end

      def chmod(path, mode, opts = {})
        recursive = opts[:recursive]

        command =
          if mode.instance_of?(String) && (mode.include?(',') || /[=+-]/.match(mode))
            Kanrisuru::Command.new("chmod #{mode} #{path}")
          elsif mode.instance_of?(Kanrisuru::Mode)
            Kanrisuru::Command.new("chmod #{mode.numeric} #{path}")
          else
            mode = Kanrisuru::Mode.new(mode)
            Kanrisuru::Command.new("chmod #{mode.numeric} #{path}")
          end

        command.append_flag('-R', recursive)

        execute_shell(command)

        Kanrisuru::Result.new(command) do
          stat(path).data
        end
      end

      def chown(path, opts = {})
        owner     = opts[:owner]
        group     = opts[:group]

        uid = get_uid(owner).to_i if Kanrisuru::Util.present?(owner)
        gid = get_gid(group).to_i if Kanrisuru::Util.present?(group)

        ## Don't chown a blank owner and group.
        return false if Kanrisuru::Util.blank?(uid) && Kanrisuru::Util.blank?(gid)

        command = Kanrisuru::Command.new('chown')

        arg = ''
        arg = uid.to_s if Kanrisuru::Util.present?(uid)
        arg += ":#{gid}" if Kanrisuru::Util.present?(gid)

        command.append_value(arg)
        command.append_flag('-R', opts[:recursive])

        command << path

        execute_shell(command)

        Kanrisuru::Result.new(command) do
          stat(path).data
        end
      end

      def wc(file)
        command = Kanrisuru::Command.new("wc #{file}")
        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          items = cmd.to_s.split
          FileCount.new(items[0].to_i, items[1].to_i, items[2].to_i)
        end
      end

      private

      def backup_control_valid?(backup)
        opts = %w[
          none off numbered t existing nil simple never
        ]

        opts.include?(backup)
      end
    end
  end
end
