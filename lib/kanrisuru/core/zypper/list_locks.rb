
module Kanrisuru
  module Core
    module Zypper
      def zypper_list_locks(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command.append_flag('--quiet')
        command << 'locks'

        command.append_flag('--matches')

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a

          rows = []
          lines.each do |line|
            next if line == ''

            values = line.split(' | ')
            next if values.length != 5
            next if values[0] == '#' && values[4] == 'Repository'

            values = values.map(&:strip)

            rows << Lock.new(
              values[0].to_i,
              values[1],
              values[2].to_i,
              values[3],
              values[4]
            )
          end

          rows
        end
      end
    end
  end
end
