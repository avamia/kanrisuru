# frozen_string_literal: true

module Kanrisuru
  module Core
    module Yum
      def yum_list(opts)
        command = Kanrisuru::Command.new('yum list')

        yum_disable_repo(command, opts[:disable_repo])

        command.append_flag('all', opts[:all])
        command.append_flag('available', opts[:available])
        command.append_flag('updates', opts[:updates])
        command.append_flag('installed', opts[:installed])
        command.append_flag('extras', opts[:extras])
        command.append_flag('obsoletes', opts[:obsoletes])

        command << opts[:query] if Kanrisuru::Util.present?(opts[:query])

        pipe_output_newline(command)

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::List.parse(cmd)
        end
      end
    end
  end
end
