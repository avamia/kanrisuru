module Kanrisuru
  module Core
    module Disk
      module Du
        class Parser
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
