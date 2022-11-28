# frozen_string_literal: true

module Kanrisuru
  module Core
    module SSH
      def ssh_add(action, opts = {})
        command = Kanrisuru::Command.new('ssh-add')

        ## Quiet mode
        command.append_flag('-q')

        case action
        when 'add'
          command << Kanrisuru::Util.array_join_string(opts[:files], ' ')
        when 'remove'
          command.append_arg('-d', Kanrisuru::Util.array_join_string(opts[:files], ' '))
        when 'delete'
          command.append_flag('-D')
        when 'lock'
          command.append_arg('-x', opts[:password])
        when 'unlock'
          command.append_flag('-X')
        when 'list'
          if opts[:fingerprint]
            command.append_flag('-l')
          else
            command.append_flag('-L')
          end
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          if action == 'list'
            Parser::SSHAdd.parse(cmd, opts)
          end
        end
      end
    end
  end
end
