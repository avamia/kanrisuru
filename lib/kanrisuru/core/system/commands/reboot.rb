module Kanrisuru
  module Core
    module System
      def reboot(opts = {})
        time = opts[:time]
        cancel = opts[:cancel]
        message = opts[:message]
        no_wall = opts[:no_wall]

        command = Kanrisuru::Command.new('shutdown')

        if Kanrisuru::Util.present?(cancel)
          command.append_flag('-c')
          command << message if message
        else
          command.append_flag('-r')

          time = format_shutdown_time(time) if Kanrisuru::Util.present?(time)

          if Kanrisuru::Util.present?(no_wall)
            command.append_flag('--no-wall')
          else
            command << time if time
            command << message if message
          end
        end

        begin
          execute_shell(command)
          Kanrisuru::Result.new(command)
        rescue IOError
          ## When rebooting 'now', ssh io stream closes
          ## Set exit status to 0
          command.handle_status(0)
          Kanrisuru::Result.new(command)
        end
      end
    end
  end
end
