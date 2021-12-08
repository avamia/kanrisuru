module Kanrisuru
  module Core
    module Path
      def realpath(path, opts = {})
        command = Kanrisuru::Command.new("realpath #{path}")
        command.append_flag('-s', opts[:strip])

        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          FilePath.new(cmd.to_s)
        end
      end
    end
  end
end
