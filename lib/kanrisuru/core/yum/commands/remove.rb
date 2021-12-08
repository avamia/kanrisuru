# frozen_string_literal: true

module Kanrisuru
  module Core
    module Yum
      def yum_remove(opts)
        command = Kanrisuru::Command.new('yum remove')
        command.append_flag('-y')

        packages = Kanrisuru::Util.array_join_string(opts[:packages], ' ')
        raise ArgumentError, "can't remove yum" if packages.include?('yum')

        command << packages

        execute_shell(command)
        Kanrisuru::Result.new(command)
      end
    end
  end
end
