
module Kanrisuru
  module Core
    module Zypper
      def zypper_refresh_services(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'refresh-services'
        command.append_flag('--force', opts[:force])
        command.append_flag('--with-repos', opts[:with_repos])
        command.append_flag('--restore-status', opts[:restore_status])

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
