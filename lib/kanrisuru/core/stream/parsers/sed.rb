# frozen_string_literal: true

module Kanrisuru
  module Core
    module Stream
      module Parser
        class Sed
          def self.parse(command, opts)
            return if Kanrisuru::Util.present?(opts[:new_file])

            command.to_a.join("\n")
          end
        end
      end
    end
  end
end
