module Kanrisuru
  module Core
    module Stat
      def dir?(path)
        file_type?(path, 'directory')
      end

      def file?(path)
        file_type?(path, 'regular file')
      end

      def empty_file?(path)
        file_type?(path, 'regular empty file')
      end

      def block_device?(path)
        file_type?(path, 'block special file')
      end

      def char_device?(path)
        file_type?(path, 'character special file')
      end

      def symlink?(path)
        file_type?(path, 'symbolic link')
      end

      def inode?(path)
        command = Kanrisuru::Command.new("stat #{path}")
        command.append_arg('-c', '%i')
        execute(command)
        command.success?
      end

      def file_type?(path, type)
        command = Kanrisuru::Command.new("stat #{path}")
        command.append_arg('-c', '%F')

        execute(command)

        result = Kanrisuru::Result.new(command, &:to_s)

        result.success? ? result.data == type : false
      end

      def stat(path, opts = {})
        command = Kanrisuru::Command.new('stat')
        command.append_flag('-L', opts[:follow])
        command.append_arg('-c', '%A,%b,%D,%F,%g,%G,%h,%i,%n,%s,%u,%U,%x,%y,%z')
        command << path

        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Stat.parse(cmd)
        end
      end
    end
  end
end
