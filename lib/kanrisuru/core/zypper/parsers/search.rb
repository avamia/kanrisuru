module Kanrisuru::Core::Zypper
  module Parser
    class Search < Base 
      def self.parse(command)
        lines = command.to_a

        rows = []
        lines.each do |line|
          next if line == ''

          values = line.split('|')
          next if values.length != 6

          values = values.map(&:strip)
          next if values[0] == 'S' && values[5] == 'Repository'

          rows << Kanrisuru::Core::Zypper::SearchResult.new(
            values[5],
            values[1],
            values[0],
            values[2],
            values[3],
            values[4]
          )
        end

        rows
      end
    end
  end
end