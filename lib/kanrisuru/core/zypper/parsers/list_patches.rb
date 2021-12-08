module Kanrisuru::Core::Zypper
  module Parser
    class ListPatches < Base
      def self.parse(command)
        lines = cmd.to_a
        lines.shift
        lines.shift

        rows = []
        lines.each do |line|
          next if line == ''

          values = line.split(' | ')
          next if values.length != 7

          values = values.map(&:strip)
          next if values[0] == 'Repository' && values[6] == 'Summary'

          rows << Kanrisuru::Core::Zypper::PatchUpdate.new(
            values[0],
            values[1],
            values[2],
            values[3],
            values[4] == '---' ? '' : values[4],
            values[5],
            values[6]
          )
        end

        rows
      end
    end
  end
end