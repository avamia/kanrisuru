module Kanrisuru
  module Core
    module System
      def load_average
        command = Kanrisuru::Command.new("cat /proc/loadavg | awk '{print $1,$2,$3}'")
        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::LoadAverage.parse(cmd)
        end
      end
    end
  end
end
