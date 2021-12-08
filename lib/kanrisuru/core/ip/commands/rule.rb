# frozen_string_literal: true

module Kanrisuru
  module Core
    module IP
      def ip_rule(action, opts)
        case action
        when 'show', 'list'
          version = ip_version

          command = Kanrisuru::Command.new('ip')
          command.append_flag('-json') if version >= IPROUTE2_JSON_VERSION

          command << 'rule show'
        when 'flush'
          command = Kanrisuru::Command.new('ip rule flush')
        when 'add', 'delete'
          command = Kanrisuru::Command.new('ip rule')
          command << action

          command.append_arg('type', opts[:type])
          command.append_arg('from', opts[:from])
          command.append_arg('to', opts[:to])
          command.append_arg('iif', opts[:iif])
          command.append_arg('tos', opts[:tos])
          command.append_arg('dsfield', opts[:dsfield])
          command.append_arg('fwmark', opts[:fwmark])
          command.append_arg('priority', opts[:priority])
          command.append_arg('table', opts[:table])
          command.append_arg('realms', opts[:realms])
          command.append_arg('nat', opts[:nat])
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Rule.parse(cmd, action, version)
        end
      end
    end
  end
end
