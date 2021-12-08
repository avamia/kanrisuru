# frozen_string_literal: true

module Kanrisuru
  module Core
    module Path
      def which(program, opts = {})
        command = Kanrisuru::Command.new('which')
        command.append_flag('-a', opts[:all])
        command << program

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Which.parse(cmd)
        end
      end
    end
  end
end
