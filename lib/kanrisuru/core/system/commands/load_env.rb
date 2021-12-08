module Kanrisuru
  module Core
    module System
      def load_env
        command = Kanrisuru::Command.new('env')
        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::LoadEnv.parse(cmd)
        end
      end
    end
  end
end
