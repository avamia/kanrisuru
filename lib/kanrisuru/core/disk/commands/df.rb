# frozen_string_literal: true

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
        
        # Filesystem, Type, 1024 Blocks, Used, Available, Capacity, Mounted
        command | "awk '{print $1, $2, $3, $4, $5, $6, $7}'"

        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Df.parse(cmd)
        end
      end
    end
  end
end
