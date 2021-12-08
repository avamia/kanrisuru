# frozen_string_literal: true

module Kanrisuru
  module Core
    module Zypper
      module Parser
        class PatchCheck < Base
          def self.parse(command)
            lines = command.to_a

            rows = []
            lines.each do |line|
              next if line == ''

              values = line.split(' | ')
              next if values.length != 3

              values = values.map(&:strip)
              next if values[0] == 'Category'

              rows << Kanrisuru::Core::Zypper::PatchCount.new(
                values[0],
                values[1].to_i,
                values[2].to_i
              )
            end

            rows
          end
        end
      end
    end
  end
end
