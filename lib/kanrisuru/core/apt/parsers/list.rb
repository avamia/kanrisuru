module Kanrisuru::Core::Apt
  module Parser
    class List < Base 
      class << self 
        def parse(command)
          lines = command.to_a
          lines.shift

          result = []
          lines.each do |line|
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
