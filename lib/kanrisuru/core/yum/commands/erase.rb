# frozen_string_literal: true

module Kanrisuru
  module Core
    module Yum
      def yum_erase(opts)
        command = Kanrisuru::Command.new('yum erase')
        command.append_flag('-y')

        packages = Kanrisuru::Util.array_join_string(opts[:packages], ' ')
        raise ArgumentError, "can't erase yum" if packages.include?('yum')

        command << packages

        execute_shell(command)
        Kanrisuru::Result.new(command)
      end
    end
  end
end
