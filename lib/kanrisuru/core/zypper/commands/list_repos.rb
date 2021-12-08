# frozen_string_literal: true

module Kanrisuru
  module Core
    module Zypper
      def zypper_list_repos(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'repos'
        command.append_flag('--details')

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::ListRepos.parse(cmd)
        end
      end
    end
  end
end
