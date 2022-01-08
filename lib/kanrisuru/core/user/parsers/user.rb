# frozen_string_literal: true

module Kanrisuru
  module Core
    module User
      module Parser
        class User
          def self.parse(command)
            string = command.to_s
            string = string.split[0]

            matches = string.match(/uid=\d+\((.+)\)/)
            return if !matches || !matches.captures

            matches.captures.first
          end
        end
      end
    end
  end
end
