
module Kanrisuru
  module Core
    module Zypper
      def zypper_list_patches(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command.append_flag('--quiet')
        command << 'list-patches'

        command.append_arg('--bugzilla', opts[:bugzilla])
        command.append_arg('--cve', opts[:cve])
        command.append_arg('--date', opts[:date])

        zypper_patch_category_opt(command, opts)
        zypper_patch_severity_opt(command, opts)

        command.append_flag('--issues', opts[:issues])
        command.append_flag('--all', opts[:all])
        command.append_flag('--with-optional', opts[:with_optional])
        command.append_flag('--without-optional', opts[:without_optional])

        zypper_repos_opt(command, opts)

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::ListPatches.parse(cmd)
        end
      end
    end
  end
end
