# frozen_string_literal: true

module Kanrisuru
  module Core
    module System
      module Parser
        class LoadAverage
          def self.parse(command)
            command.to_s.split.map(&:to_f)
          end
        end
      end
    end
  end
end
