module Kanrisuru
  module Core
    module File
      def copy(source, dest, opts = {})
        cp(source, dest, opts)
      end
      
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