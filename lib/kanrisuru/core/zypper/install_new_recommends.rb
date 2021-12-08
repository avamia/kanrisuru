
module Kanrisuru
  module Core
    module Zypper
      def zypper_install_new_recommends(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'install-new-recommends'

        command.append_flag('--dry-run', opts[:dry_run])

        zypper_repos_opt(command, opts)
        zypper_solver_opts(command, opts)
        zypper_expert_opts(command, opts)

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
