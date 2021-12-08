module Kanrisuru
  module Core
    module Apt
      def apt_list(opts)
        command = Kanrisuru::Command.new('apt list')
        command.append_flag('--installed', opts[:installed])
        command.append_flag('--upgradeable', opts[:upgradeable])
        command.append_flag('--all-versions', opts[:all_versions])
        command.append_arg('-a', opts[:package_name])

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a
          lines.shift

          result = []
          lines.each do |line|
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
