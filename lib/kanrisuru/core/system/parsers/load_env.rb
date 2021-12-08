module Kanrisuru::Core::System
  module Parser
    class LoadEnv
      def self.parse(command)
        string = command.to_s
        hash = {}

        rows = string.split("\n")
        rows.each do |row|
          key, value = row.split('=', 2)
          hash[key] = value
        end

        hash
      end
    end
  end
end