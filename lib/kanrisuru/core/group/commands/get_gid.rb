module Kanrisuru
  module Core
    module Group
      def get_gid(group)
        command = Kanrisuru::Command.new("getent group #{group}")

        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Gid.parse(cmd)
        end
      end
    end
  end
end
