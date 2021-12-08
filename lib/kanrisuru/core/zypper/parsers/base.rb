module Kanrisuru::Core::Zypper
  module Parser
    class  Base 
      class << self
        def extract_single_zypper_line(line)
          values = line.split(': ', 2)
          values.length == 2 ? values[1] : ''
        end
      end
    end
  end
end