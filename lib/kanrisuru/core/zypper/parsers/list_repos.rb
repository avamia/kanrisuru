module Kanrisuru::Core::Zypper
  module Parser
    class ListRepos < Base 
      def self.parse(command)
        lines = command.to_a

        rows = []
        lines.each do |line|
          next unless line.match(/^\d/)

          values = line.split('|')
          values = values.map(&:strip)

          rows << Kanrisuru::Core::Zypper::Repo.new(
            values[0].to_i,
            values[1],
            values[2],
            values[3] == 'Yes',
            values[4].include?('Yes'),
            values[5] == 'Yes',
            values[6].to_i,
            values[7],
            values[8],
            values.length == 10 ? values[9] : nil
          )
        end
        rows
      end
    end
  end
end