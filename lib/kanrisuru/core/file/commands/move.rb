module Kanrisuru
  module Core
    module File
      def move(source, dest, opts = {})
        mv(source, dest, opts)
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
          command.append_array(source)
        else
          command.append_array(source)
          command << dest
        end

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
