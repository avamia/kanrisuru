# frozen_string_literal: true

module Kanrisuru
  module Core
    module Find
      module Parser
        class Find
          def self.parse(command)
            rows = command.to_a
            rows.map do |row|
              Kanrisuru::Core::Find::FilePath.new(row)
            end
          end
        end
      end
    end
  end
end
