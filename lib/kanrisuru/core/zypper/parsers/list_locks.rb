module Kanrisuru::Core::Zypper
  module Parser
    class ListLocks < Base 
      def self.parse(command)
        lines = command.to_a

        rows = []
        lines.each do |line|
          next if line == ''

          values = line.split(' | ')
          next if values.length != 5
          next if values[0] == '#' && values[4] == 'Repository'

          values = values.map(&:strip)

          rows << Kanrisuru::Core::Zypper::Lock.new(
            values[0].to_i,
            values[1],
            values[2].to_i,
            values[3],
            values[4]
          )
        end

        rows
      end
    end
  end
end