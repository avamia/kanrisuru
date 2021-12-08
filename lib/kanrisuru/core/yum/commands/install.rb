# frozen_string_literal: true

module Kanrisuru
  module Core
    module Yum
      def yum_install(opts)
        command = Kanrisuru::Command.new('yum install')
        command.append_flag('-y')

        packages = Kanrisuru::Util.array_join_string(opts[:packages], ' ')
        command << packages

        execute_shell(command)
        Kanrisuru::Result.new(command)
      end
    end
  end
end
