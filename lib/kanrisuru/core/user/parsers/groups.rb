# frozen_string_literal: true

module Kanrisuru
  module Core
    module User
      module Parser
        class Groups
          def self.parse(command)
            string = command.to_s
            string = string.split('groups=')[1]
            string.gsub(/\(/, '').gsub(/\)/, '').split(',')
          end
        end
      end
    end
  end
end
