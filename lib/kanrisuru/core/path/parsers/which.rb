module Kanrisuru::Core::Path
  module Parser
    class Which
      def self.parse(command)
        rows = command.to_a
        rows.map do |row|
          FilePath.new(row)
        end
      end
    end
  end
end