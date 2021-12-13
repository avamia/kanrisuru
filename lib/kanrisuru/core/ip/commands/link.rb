# frozen_string_literal: true

module Kanrisuru
  module Core
    module IP
      def ip_link(action, opts)
        case action
        when 'show', 'list'
          version = ip_version.to_i
          command = ip_link_show(opts, version)
        when 'add', 'a'
          command = ip_link_add(opts)
        when 'delete', 'del'
          command = ip_link_delete(opts)
        when 'set'
          command = ip_link_set(opts)
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Link.parse(cmd, action, version)
        end
      end

      def ip_link_show(opts, version)
        command = Kanrisuru::Command.new('ip')
        command.append_flag('-json') if version >= IPROUTE2_JSON_VERSION
        command.append_flag('-s', opts[:stats])
        command.append_arg('-family', opts[:family])
        command << 'link show'

        command.append_arg('dev', opts[:dev])
        command.append_arg('group', opts[:group])
        command.append_arg('master', opts[:master])
        command.append_arg('type', opts[:type])
        command.append_arg('vrf', opts[:vrf])

        command.append_flag('up', opts[:up])
        command
      end

      def ip_link_add(opts)
        command = Kanrisuru::Command.new('ip link add')

        command.append_arg('dev', opts[:dev])
        command.append_arg('name', opts[:name])
        command.append_arg('mtu', opts[:mtu])
        command.append_arg('index', opts[:index])

        command.append_arg('numtxqueues', opts[:numtxqueues])
        command.append_arg('numrxqueues', opts[:numrxqueues])
        command.append_arg('gso_max_size', opts[:gso_max_size])
        command.append_arg('gso_max_segs', opts[:gso_max_segs])

        if Kanrisuru::Util.present?(opts[:type])
          raise ArgumentError, 'invalid link type' unless IP_LINK_TYPES.include?(opts[:type])

          command.append_arg('type', opts[:type])

          ip_link_type_opts(command, opts) if Kanrisuru::Util.present?(opts[:type_opts])
        end

        command
      end

      def ip_link_delete(opts)
        command = Kanrisuru::Command.new('ip link delete')
        command.append_arg('dev', opts[:dev])
        command.append_arg('group', opts[:group])
        command.append_arg('type', opts[:type])
        command
      end

      def ip_link_set(opts)
        command = Kanrisuru::Command.new('ip link set')
        raise ArgumentError, 'no device defined' unless opts[:dev]

        command.append_arg('dev', opts[:dev])
        command.append_arg('group', opts[:group])

        case opts[:direction]
        when 'up'
          command.append_flag('up')
        when 'down'
          command.append_flag('down')
        end

        ip_link_common_opts(command, opts)

        ip_link_vf_opts(command, opts) if Kanrisuru::Util.present?(opts[:vf])

        ip_link_xdp_opts(command, opts) if Kanrisuru::Util.present?(opts[:xdp])

        if opts[:master] == false
          command.append_flag('nomaster')
        else
          command.append_arg('master', opts[:master])
        end

        command.append_arg('addrgenmode', opts[:addrgenmode])
        command.append_flag('link-netnsid', opts[:link_netnsid])

        if Kanrisuru::Util.present?(opts[:type])
          raise ArgumentError, 'invalid link type' unless IP_LINK_TYPES.include?(opts[:type])

          command.append_arg('type', opts[:type])

          ip_link_type_opts(command, opts) if Kanrisuru::Util.present?(opts[:type_opts])
        end

        command
      end
    end
  end
end
