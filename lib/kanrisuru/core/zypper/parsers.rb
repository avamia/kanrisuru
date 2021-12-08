
module Kanrisuru
  module Core
    module Zypper
      def extract_single_zypper_line(line)
        values = line.split(': ', 2)
        values.length == 2 ? values[1] : ''
      end
    end
  end
end