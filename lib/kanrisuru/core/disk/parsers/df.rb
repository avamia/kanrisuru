module Kanrisuru::Core::Disk
  module Parser
    class Df
      class << self
        def parse(command)
          items = []
          rows = command.to_a
          rows.each.with_index do |row, index|
            next if index.zero?

            values = row.split

            items << Kanrisuru::Core::Disk::DiskFree.new(
              values[0],
              values[1],
              values[2].to_i,
              values[3].to_i,
              values[4].to_i,
              values[5]
            )
          end
          items
        end
      end
    end
  end
end
