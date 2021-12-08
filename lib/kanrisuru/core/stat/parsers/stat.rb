# frozen_string_literal: true

module Kanrisuru
  module Core
    module Stat
      module Parser
        class Stat
          def self.parse(command)
            string = command.to_s
            values = string.split(',')

            Kanrisuru::Core::Stat::FileStat.new(
              Kanrisuru::Mode.new(values[0]),
              values[1].to_i,
              values[2],
              values[3],
              values[4].to_i,
              values[5],
              values[6].to_i,
              values[7].to_i,
              values[8],
              values[9].to_i,
              values[10].to_i,
              values[11],
              values[12] ? DateTime.parse(values[12]) : nil,
              values[13] ? DateTime.parse(values[13]) : nil,
              values[14] ? DateTime.parse(values[14]) : nil
            )
          end
        end
      end
    end
  end
end
