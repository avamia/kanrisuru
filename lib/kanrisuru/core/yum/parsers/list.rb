# frozen_string_literal: true

module Kanrisuru
  module Core
    module Yum
      module Parser
        class List < Base
          def self.parse(command)
            lines = command.to_a
            result = []
            lines.each do |line|
              item = parse_yum_line(line)
              next unless item

              result << item
            end

            result
          end
        end
      end
    end
  end
end
