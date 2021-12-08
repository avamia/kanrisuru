
module Kanrisuru
  module Core
    module Zypper
      def zypper_list_repos(opts)
        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)

        command << 'repos'
        command.append_flag('--details')

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a

          rows = []
          lines.each do |line|
            next unless line.match(/^\d/)

            values = line.split('|')
            values = values.map(&:strip)

            rows << Repo.new(
              values[0].to_i,
              values[1],
              values[2],
              values[3] == 'Yes',
              values[4].include?('Yes'),
              values[5] == 'Yes',
              values[6].to_i,
              values[7],
              values[8],
              values.length == 10 ? values[9] : nil
            )
          end
          rows
        end
      end
    end
  end
end
