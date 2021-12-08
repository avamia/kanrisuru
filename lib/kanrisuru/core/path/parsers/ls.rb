# frozen_string_literal: true

module Kanrisuru
  module Core
    module Path
      module Parser
        class Ls
          def self.parse(command, id)
            items = []
            rows = command.to_a

            rows.each.with_index do |row, index|
              next if index.zero?

              values = row.split
              date = DateTime.parse("#{values[6]} #{values[7]} #{values[8]}")

              type = values[1].include?('d') ? 'directory' : 'file'
              items <<
                if id
                  Kanrisuru::Core::Path::FileInfo.new(
                    values[0].to_i,
                    Kanrisuru::Mode.new(values[1]),
                    values[2].to_i,
                    values[3].to_i,
                    values[4].to_i,
                    values[5].to_i,
                    date,
                    values[9],
                    type
                  )
                else
                  Kanrisuru::Core::Path::FileInfo.new(
                    values[0].to_i,
                    Kanrisuru::Mode.new(values[1]),
                    values[2].to_i,
                    values[3],
                    values[4],
                    values[5].to_i,
                    date,
                    values[9],
                    type
                  )
                end
            end

            items
          end
        end
      end
    end
  end
end
