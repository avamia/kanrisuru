# frozen_string_literal: true

module Kanrisuru
  module Core
    module Disk
      module Parser
        class Du
          class << self
            def parse(command, convert)
              lines = command.to_a

              lines.map do |line|
                values = line.split
                size = values[0].to_i
                size = convert ? Kanrisuru::Util::Bits.convert_bytes(size, :byte, convert) : size

                Kanrisuru::Core::Disk::DiskUsage.new(size, values[1])
              end
            end
          end
        end
      end
    end
  end
end
