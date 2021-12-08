# frozen_string_literal: true

module Kanrisuru
  module Core
    module IP
      def ip_maddress(action, opts)
        case action
        when 'show', 'list'
          command = Kanrisuru::Command.new('ip')

          version = ip_version
          command.append_flag('-json') if version >= IPROUTE2_JSON_VERSION
          command.append_arg('-family', opts[:family])
          command << 'maddress show'

          command.append_arg('dev', opts[:dev])
        when 'add', 'delete', 'del'
          command = Kanrisuru::Command.new('ip maddress')
          command << action

          command.append_arg('address', opts[:lladdress])
          command.append_arg('dev', opts[:dev])
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Maddress.parse(cmd, action, version)
        end
      end
    end
  end
end
