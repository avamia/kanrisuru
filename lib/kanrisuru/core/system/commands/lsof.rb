# frozen_string_literal: true

module Kanrisuru
  module Core
    module System
      def lsof(_opts = {})
        command = Kanrisuru::Command.new('lsof -F pcuftDsin')
        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Lsof.parse(cmd)
        end
      end
    end
  end
end
