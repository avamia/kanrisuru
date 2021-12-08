
module Kanrisuru
  module Core
    module Disk
      def df(opts = {})
        path   = opts[:path]
        inodes = opts[:inodes]

        command = Kanrisuru::Command.new('df')

        command.append_flag('-PT')
        command.append_flag('-i', inodes)

        command << path if Kanrisuru::Util.present?(path)
        command | "awk '{print $1, $2, $3, $5, $6, $7}'"

        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          Kanrisuru::Core::Disk::Df::Parser.parse(cmd)
        end
      end
    end
  end
end
