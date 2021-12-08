module Kanrisuru
  module Core
    module Path
      def readlink(path, opts = {})
        command = Kanrisuru::Command.new('readlink')
        command.append_flag('-f', opts[:canonicalize])
        command.append_flag('-e', opts[:canonicalize_existing])
        command.append_flag('-m', opts[:canonicalize_missing])

        command << path

        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          FilePath.new(cmd.to_s)
        end
      end
    end
  end
end