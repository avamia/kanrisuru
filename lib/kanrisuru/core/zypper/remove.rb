
module Kanrisuru
  module Core
    module Zypper
      def zypper_remove(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'remove'

        command.append_flag('--dry-run', opts[:dry_run])
        command.append_flag('--capability', opts[:capability])

        zypper_repos_opt(command, opts)
        zypper_package_type_opt(command, opts)
        zypper_solver_opts(command, opts)

        packages = Kanrisuru::Util.array_join_string(opts[:packages], ' ')
        command << packages

        execute_shell(command)
        Kanrisuru::Result.new(command)
      end
    end
  end
end
