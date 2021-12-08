module Kanrisuru::Core::Find
  module Parser
    class Find
      def self.parse(command)
        rows = cmd.to_a
        rows.map do |row|
          Kanrsiru::Core::Find::FilePath.new(row)
        end
      end
    end
  end
end
