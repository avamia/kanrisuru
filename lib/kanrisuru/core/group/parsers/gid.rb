module Kanrisuru::Core::Group
  module Parser
    class Gid
      def self.parse(command)
        command.to_s.split(':')[2].to_i 
      end
    end
  end
end
