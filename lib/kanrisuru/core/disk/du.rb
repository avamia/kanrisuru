
module Kanrisuru
  module Core
    module Disk
      def du(opts = {})
        path      = opts[:path]
        summarize = opts[:summarize]
        convert   = opts[:convert]

        command = Kanrisuru::Command.new('du')
        command.append_flag('-s', summarize)
        command << path if Kanrisuru::Util.present?(path)
        command | "awk '{print \\$1, \\$2}'"

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Kanrisuru::Core::Disk::Du::Parser.parse(cmd, convert)
        end
      end
    end
  end
end
