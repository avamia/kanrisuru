module Kanrisuru
  module Core
    module Yum
      def extract_single_yum_line(line)
        values = line.split(': ', 2)
        values.length == 2 ? values[1] : ''
      end

      def parse_yum_line(line)
        values = line.split
        return if values.length != 3
        return unless /^\w+\.\w+$/i.match(values[0])

        full_name = values[0]
        version = values[1]

        name, architecture = full_name.split('.')

        PackageOverview.new(name, architecture, version)
      end
    end
  end
end
