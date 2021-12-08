
module Kanrisuru
  module Core
    module Zypper
      def zypper_patch_check(opts)
        command = Kanrisuru::Command.new('zypper')
        command.append_valid_exit_code(EXIT_INF_UPDATE_NEEDED)
        command.append_valid_exit_code(EXIT_INF_SEC_UPDATE_NEEDED)

        zypper_global_opts(command, opts)
        command.append_flag('--quiet')
        command << 'patch-check'

        command.append_flag('--updatestack-only', opts[:updatestack_only])
        command.append_flag('--with-optional', opts[:with_optional])
        command.append_flag('--without-optional', opts[:without_optional])

        zypper_repos_opt(command, opts)

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::PatchCheck.parse(cmd)
        end
      end
    end
  end
end
