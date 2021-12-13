# frozen_string_literal: true

module Kanrisuru
  module Core
    module IP
      def ip_address_label(action, opts)
        case action
        when 'show', 'list'
          version = ip_version.to_i
          command = ip_address_label_show(opts, version)
        when 'flush'
          command = ip_address_label_flush(opts)
        when 'add'
          command = ip_address_label_add(opts)
        when 'del'
          command = ip_address_label_delete(opts)
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::AddressLabel.parse(cmd, action, version)
        end
      end

      def ip_address_label_delete(opts)
        command = Kanrisuru::Command.new('ip addrlabel del')
        command.append_arg('prefix', opts[:prefix])
        command.append_arg('dev', opts[:dev])
        command.append_arg('label', opts[:label])
        command
      end

      def ip_address_label_add(opts)
        command = Kanrisuru::Command.new('ip addrlabel add')
        command.append_arg('prefix', opts[:prefix])
        command.append_arg('dev', opts[:dev])
        command.append_arg('label', opts[:label])
        command
      end

      def ip_address_label_flush(_opts)
        Kanrisuru::Command.new('ip addrlabel flush')
      end

      def ip_address_label_show(_opts, version)
        command = Kanrisuru::Command.new('ip')
        command.append_flag('-json') if version >= IPROUTE2_JSON_VERSION
        command << 'addrlabel list'
        command
      end
    end
  end
end
