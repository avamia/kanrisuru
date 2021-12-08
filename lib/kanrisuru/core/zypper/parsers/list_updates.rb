module Kanrisuru::Core::Zypper
  module Parser
    class ListUpdates < Base 
      def self.parse(command)
        lines = cmd.to_a
        lines.shift

        rows = []
        lines.each do |line|
          values = line.split(' | ')
          values = values.map(&:strip)

          rows << Kanrisuru::Core::Zypper::PackageUpdate.new(
            values[1],
            values[2],
            values[3],
            values[4],
            values[5]
          )
        end

        rows
      end
    end
  end
end