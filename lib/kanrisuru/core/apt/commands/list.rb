module Kanrisuru
  module Core
    module Apt
      def apt_list(opts)
        command = Kanrisuru::Command.new('apt list')
        command.append_flag('--installed', opts[:installed])
        command.append_flag('--upgradeable', opts[:upgradeable])
        command.append_flag('--all-versions', opts[:all_versions])
        command.append_arg('-a', opts[:package_name])

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::List.parse(cmd)
        end
      end
    end
  end
end
