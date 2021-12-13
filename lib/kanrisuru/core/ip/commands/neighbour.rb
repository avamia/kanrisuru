# frozen_string_literal: true

module Kanrisuru
  module Core
    module IP
      def ip_neighbour(action, opts)
        case action
        when 'show', 'list'
          version = ip_version.to_i
          command = ip_neighbour_show(opts, version)
        when 'add', 'change', 'replace', 'del', 'delete'
          command = ip_neighbour_modify(action, opts)
        when 'flush'
          command = ip_neighbour_flush(opts)
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Neighbour.parse(cmd, action, version)
        end
      end

      def ip_neighbour_show(opts, version)
        command = Kanrisuru::Command.new('ip')
        command.append_flag('-json') if version >= IPROUTE2_JSON_VERSION
        command.append_flag('-s', opts[:stats])

        command << 'neighbour show'

        command.append_arg('to', opts[:to])
        command.append_arg('dev', opts[:dev])
        command.append_arg('nud', opts[:nud])

        command.append_flag('proxy', opts[:proxy])
        command.append_flag('unused', opts[:unused])
        command
      end

      def ip_neighbour_modify(action, opts)
        command = Kanrisuru::Command.new('ip neighbour')
        command << action

        command.append_arg('to', opts[:to])
        command.append_arg('dev', opts[:dev])

        if action != 'del' && action != 'delete'
          command.append_arg('lladdr', opts[:lladdr])
          command.append_arg('nud', opts[:nud])
        end

        command.append_flag('proxy', opts[:proxy])
        command.append_flag('router', opts[:router])
        command.append_flag('extern_learn', opts[:extern_learn])
        command
      end

      def ip_neighbour_flush(opts)
        command = Kanrisuru::Command.new('ip')
        command.append_flag('-s', opts[:stats])
        command << 'neighbour flush'

        command.append_arg('to', opts[:to])
        command.append_arg('dev', opts[:dev])
        command.append_arg('nud', opts[:nud])

        command.append_flag('unused', opts[:unused])
        command
      end
    end
  end
end
