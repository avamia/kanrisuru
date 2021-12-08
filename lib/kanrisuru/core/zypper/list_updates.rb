
module Kanrisuru
  module Core
    module Zypper
      def zypper_list_updates(opts)
        return zypper_list_patches(opts) if opts[:type] == 'patch'

        command = Kanrisuru::Command.new('zypper')
        zypper_global_opts(command, opts)
        command.append_flag('--quiet')
        command << 'list-updates'

        zypper_repos_opt(command, opts)
        zypper_package_type_opt(command, opts)

        command.append_flag('--all', opts[:all])
        command.append_flag('--best-effort', opts[:best_effort])

        zypper_expert_opts(command, opts)

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a
          lines.shift

          rows = []
          lines.each do |line|
            values = line.split(' | ')
            values = values.map(&:strip)

            rows << PackageUpdate.new(
              values[1],
              values[2],
              values[3],
              values[4],
              values[5]
            )
          end

          rows
        end
      end
    end
  end
end
