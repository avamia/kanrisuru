module Kanrisuru
  module Core
    module Apt
      def apt_search(opts)
        command = Kanrisuru::Command.new('apt search')
        command << opts[:query]

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a
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