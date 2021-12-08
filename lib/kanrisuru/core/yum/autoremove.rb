module Kanrisuru
  module Core
    module Yum
      def yum_autoremove(_opts)
        command = Kanrisuru::Command.new('yum autoremove')
        command.append_flag('-y')
        execute_shell(command)
        Kanrisuru::Result.new(command)
      end
    end
  end
end