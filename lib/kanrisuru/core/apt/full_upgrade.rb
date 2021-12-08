module Kanrisuru
  module Core
    module Apt
      def apt_full_upgrade(_opts)
        command = Kanrisuru::Command.new('apt full-upgrade')
        command.append_flag('-y')
        execute_shell(command)
        Kanrisuru::Result.new(command)
      end
    end
  end
end
