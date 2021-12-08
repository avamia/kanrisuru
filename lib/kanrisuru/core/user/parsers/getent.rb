# frozen_string_literal: true

module Kanrisuru
  module Core
    module User
      module Parser
        class Getent
          def self.parse(command)
            command.to_s.split.map do |value|
              Kanrisuru::Core::User::FilePath.new(value)
            end
          end
        end
      end
    end
  end
end
