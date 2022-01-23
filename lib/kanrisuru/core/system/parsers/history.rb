# frozen_string_literal: true

module Kanrisuru
  module Core
    module System
      module Parser
        class History
          def self.parse(command)
            lines = command.to_a
            lines.map do |line|
              line.split(/^\d+\s+/)[1]
            end
          end
        end
      end
    end
  end
end
