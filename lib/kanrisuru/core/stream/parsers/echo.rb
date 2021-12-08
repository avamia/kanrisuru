# frozen_string_literal: true

module Kanrisuru
  module Core
    module Stream
      module Parser
        class Echo
          def self.parse(command, opts)
            return if Kanrisuru::Util.present?(opts[:new_file])

            command.to_s
          end
        end
      end
    end
  end
end
