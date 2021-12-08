# frozen_string_literal: true

module Kanrisuru
  module Core
    module Zypper
      def zypper_info(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command << 'info'

        zypper_repos_opt(command, opts)
        zypper_package_type_opt(command, opts)

        packages = Kanrisuru::Util.array_join_string(opts[:packages], ' ')
        command << packages

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Info.parse(cmd)
        end
      end
    end
  end
end
