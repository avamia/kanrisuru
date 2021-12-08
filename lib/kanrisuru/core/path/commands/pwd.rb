# frozen_string_literal: true

module Kanrisuru
  module Core
    module Path
      def pwd
        command = Kanrisuru::Command.new('pwd')
        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          FilePath.new(cmd.to_s)
        end
      end
    end
  end
end
