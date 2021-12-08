# frozen_string_literal: true

module Kanrisuru
  module Core
    module Apt
      module Parser
        class Search < Base
          class << self
            def parse(command)
              lines = command.to_a
              lines.shift
              lines.shift

              result = []

              lines.each do |line|
                next unless line.include?('/')

                item = parse_apt_line(line)
                next unless item

                result << item
              end

              result
            end
          end
        end
      end
    end
  end
end
