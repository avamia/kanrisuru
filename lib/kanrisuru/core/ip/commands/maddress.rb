# frozen_string_literal: true

module Kanrisuru
  module Core
    module IP
      def ip_maddress(action, opts)
        case action
        when 'show', 'list'
          version = ip_version.to_i
          command = ip_maddress_show(opts, version)
        when 'add', 'delete', 'del'
          command = ip_maddress_modify(action, opts)
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Maddress.parse(cmd, action, version)
        end
      end

      def ip_maddress_show(opts, version)
        command = Kanrisuru::Command.new('ip')
        command.append_flag('-json') if version >= IPROUTE2_JSON_VERSION
        command.append_arg('-family', opts[:family])
        command << 'maddress show'

        command.append_arg('dev', opts[:dev])
        command
      end

      def ip_maddress_modify(action, opts)
        command = Kanrisuru::Command.new('ip maddress')
        command << action

        command.append_arg('address', opts[:address])
        command.append_arg('dev', opts[:dev])
        command
      end
    end
  end
end
