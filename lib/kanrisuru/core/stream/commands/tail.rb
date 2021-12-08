module Kanrisuru
  module Core
    module Stream
      def tail(path, opts = {})
        command = Kanrisuru::Command.new('tail')
        command.append_arg('-c', opts[:bytes])
        command.append_arg('-n', opts[:lines])
        command << path

        execute_shell(command)

        Kanrisuru::Result.new(command, &:to_a)
      end
    end
  end
end