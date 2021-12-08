# frozen_string_literal: true

module Kanrisuru
  module Core
    module File
      def wc(file)
        command = Kanrisuru::Command.new("wc #{file}")
        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Wc.parse(cmd)
        end
      end
    end
  end
end
