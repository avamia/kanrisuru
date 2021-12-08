module Kanrisuru
  module Core
    module Path
      def whoami
        command = Kanrisuru::Command.new('whoami')
        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          UserName.new(cmd.to_s)
        end
      end
    end
  end
end
