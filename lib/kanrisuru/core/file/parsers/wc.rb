# frozen_string_literal: true

module Kanrisuru
  module Core
    module File
      module Parser
        class Wc
          def self.parse(command)
            items = command.to_s.split
            Kanrisuru::Core::File::FileCount.new(items[0].to_i, items[1].to_i, items[2].to_i)
          end
        end
      end
    end
  end
end
