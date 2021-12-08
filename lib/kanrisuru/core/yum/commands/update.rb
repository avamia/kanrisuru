# frozen_string_literal: true

module Kanrisuru
  module Core
    module Yum
      def yum_update(_opts)
        command = Kanrisuru::Command.new('yum update')
        command.append_flag('-y')
        execute_shell(command)
        Kanrisuru::Result.new(command)
      end
    end
  end
end
