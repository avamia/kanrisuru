module Kanrisuru::Core::User
  module Parser
    class Getent 
      def self.parse(command)
        command.to_s.split.map do |value| 
          Kanrisuru::Core::User::FilePath.new(value)
        end
      end
    end
  end
end