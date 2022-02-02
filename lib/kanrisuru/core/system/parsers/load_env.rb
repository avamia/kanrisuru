# frozen_string_literal: true

module Kanrisuru
  module Core
    module System
      module Parser
        class LoadEnv
          def self.parse(command)
            rows = command.to_a
            hash = {}

            rows.each do |row|
              key, value = row.split('=')
              hash[key] = value
            end

            hash
          end
        end
      end
    end
  end
end
