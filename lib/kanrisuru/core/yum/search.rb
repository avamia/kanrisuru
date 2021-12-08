module Kanrisuru
  module Core
    module Yum
      def yum_search(opts)
        command = Kanrisuru::Command.new('yum search')
        command.append_flag('all', opts[:all])
        command << Kanrisuru::Util.array_join_string(opts[:packages], ' ')

        pipe_output_newline(command)

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a

          result = []
          lines.each do |line|
            line = line.gsub(/\s{2}/, '')
            values = line.split(' : ')
            next if values.length != 2

            full_name = values[0]
            name, architecture = full_name.split('.')
            summary = values[1]

            result << PackageSearchResult.new(name, architecture, summary)
          end

          result
        end
      end
    end
  end
end