module Kanrisuru::Core::Group
  module Parser
    class Group
      def self.parse(command)
        command.to_s.split(',')
      end
    end
  end
end
