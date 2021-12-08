module Kanrisuru::Core::File
  module Parser
    class Wc
      def self.parse(command)
        items = command.to_s.split
        Kanrisuru::Core::File::FileCount.new(items[0].to_i, items[1].to_i, items[2].to_i)
      end
    end
  end
end
