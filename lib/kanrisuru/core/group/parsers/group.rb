# frozen_string_literal: true

module Kanrisuru
  module Core
    module Group
      module Parser
        class Group
          def self.parse(command)
            command.to_s.split(',')
          end
        end
      end
    end
  end
end
