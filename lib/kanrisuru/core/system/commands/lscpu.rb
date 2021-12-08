# frozen_string_literal: true

module Kanrisuru
  module Core
    module System
      def lscpu
        command = Kanrisuru::Command.new('lscpu')

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Lscpu.parse(cmd)
        end
      end
    end
  end
end
