module Kanrisuru
  module Core
    module Group
      def delete_group(group)
        return false unless group?(group)

        command = Kanrisuru::Command.new("groupdel #{group}")
        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
