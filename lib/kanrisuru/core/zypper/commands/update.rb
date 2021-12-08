
module Kanrisuru
  module Core
    module Zypper
      def zypper_update(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'update'

        zypper_repos_opt(command, opts)
        zypper_package_type_opt(command, opts)

        command.append_flag('--replacefiles', opts[:replacefiles])
        command.append_flag('--dry-run', opts[:dry_run])
        command.append_flag('--best-effort', opts[:best_effort])

        zypper_solver_opts(command, opts)
        zypper_expert_opts(command, opts)

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
