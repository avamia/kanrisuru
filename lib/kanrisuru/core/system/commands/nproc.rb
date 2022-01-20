# frozen_string_literal: true

module Kanrisuru
  module Core
    module System
      def nproc(opts = {})
        command = Kanrisuru::Command.new('nproc')
        command.append_flag('--all', opts[:all])
        execute_shell(command)

        Kanrisuru::Result.new(command, &:to_i)
      end
    end
  end
end
