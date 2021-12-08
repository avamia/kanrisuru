
module Kanrisuru
  module Core
    module Zypper
      def zypper_refresh_repos(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'refresh'

        command.append_flag('--force', opts[:force])
        command.append_flag('--force-build', opts[:force_build])
        command.append_flag('--force-download', opts[:force_download])
        command.append_flag('--build-only', opts[:build_only])
        command.append_flag('--download-only', opts[:download_only])

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
