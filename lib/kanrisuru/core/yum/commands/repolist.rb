module Kanrisuru
  module Core
    module Yum
      def yum_repolist(opts)
        command = Kanrisuru::Command.new('yum repolist')
        command.append_flag('--verbose')

        command << Kanrisuru::Util.array_join_string(opts[:repos], ' ') if opts[:repos]

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Repolist.parse(cmd)
        end
      end
    end
  end
end