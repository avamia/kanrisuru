# frozen_string_literal: true

module Kanrisuru
  module Core
    module Yum
      def yum_search(opts)
        command = Kanrisuru::Command.new('yum search')
        command.append_flag('all', opts[:all])
        command << Kanrisuru::Util.array_join_string(opts[:packages], ' ')

        pipe_output_newline(command)

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Search.parse(cmd)
        end
      end
    end
  end
end
