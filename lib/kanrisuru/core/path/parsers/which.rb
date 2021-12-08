# frozen_string_literal: true

module Kanrisuru
  module Core
    module Path
      module Parser
        class Which
          def self.parse(command)
            rows = command.to_a
            rows.map do |row|
              FilePath.new(row)
            end
          end
        end
      end
    end
  end
end
