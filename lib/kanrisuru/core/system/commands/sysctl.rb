# frozen_string_literal: true

module Kanrisuru
  module Core
    module System
      def sysctl(variable = nil)
        command = Kanrisuru::Command.new('sysctl')

        ## Some older versions have a bug with 255 exit code being returned
        command.append_valid_exit_code(255)

        if Kanrisuru::Util.present?(variable)
          command << variable
        else
          command.append_flag('--all')
        end
        
        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Sysctl.parse(cmd)
        end
      end
    end
  end
end
