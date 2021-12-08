
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
          Parser::ListLocks.parse(cmd)
        end
      end
    end
  end
end
