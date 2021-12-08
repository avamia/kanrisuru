# frozen_string_literal: true

module Kanrisuru
  module Core
    module Yum
      def yum_upgrade(_opts)
        command = Kanrisuru::Command.new('yum upgrade')
        command.append_flag('-y')
        execute_shell(command)
        Kanrisuru::Result.new(command)
      end
    end
  end
end
