module Kanrisuru
  module Core
    module Apt
      def apt_update(_opts)
        command = Kanrisuru::Command.new('apt-get update')
        command.append_flag('-y')
        execute_shell(command)
        Kanrisuru::Result.new(command)
      end
    end
  end
end
