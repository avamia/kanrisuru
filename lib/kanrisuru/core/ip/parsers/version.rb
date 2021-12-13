# frozen_string_literal: true

module Kanrisuru
  module Core
    module IP
      module Parser
        class Version < Base
          def self.parse(command)
            command.to_s.split('ip utility, iproute2-ss')[1].to_i
          end
        end
      end
    end
  end
end
