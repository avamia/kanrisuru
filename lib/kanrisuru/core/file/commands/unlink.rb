module Kanrisuru
  module Core
    module File
      def unlink(path)
        command = Kanrisuru::Command.new("unlink #{path}")
        execute_shell(command)
        Kanrisuru::Result.new(command)
      end
    end
  end
end