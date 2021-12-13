# frozen_string_literal: true

module Kanrisuru
  module Core
    module IP
      def ip_link_common_opts(command, opts)
        command.append_arg('arp', opts[:arp])
        command.append_arg('multicast', opts[:multicast])
        command.append_arg('allmulticast', opts[:allmulticast])
        command.append_arg('promisc', opts[:promisc])
        command.append_arg('protodown', opts[:protodown])
        command.append_arg('protodown_reason', opts[:protodown_reason])
        command.append_arg('dynamic', opts[:dynamic])
        command.append_arg('name', opts[:name])
        command.append_arg('txqueuelen', opts[:txqueuelen])
        command.append_arg('txqlen', opts[:txqlen])
        command.append_arg('mtu', opts[:mtu])
        command.append_arg('address', opts[:address])
        command.append_arg('broadcast', opts[:broadcast])
        command.append_arg('brd', opts[:brd])
        command.append_arg('peer', opts[:peer])
        command.append_arg('netns', opts[:netns])
        command.append_arg('alias', opts[:alias])
      end

      def ip_link_xdp_opts(command, opts)
        command.append_arg('xdp', opts[:xdp])

        case opts[:xdp]
        when 'object'
          command << opts[:object]
          command.append_arg('section', opts[:section])
          command.append_flag('verbose', opts[:verbose])
        when 'pinned'
          command << opts[:pinned]
        end
      end

      def ip_link_vf_opts(command, opts)
        command.append_arg('vf', opts[:vf])
        command.append_arg('mac', opts[:mac])

        if Kanrisuru::Util.present?(opts[:vlan])
          command.append_arg('vlan', opts[:vlan])
          command.append_arg('qos', opts[:qos])
        end

        command.append_arg('proto', opts[:proto])
        command.append_arg('rate', opts[:rate])
        command.append_arg('max_tx_rate', opts[:max_tx_rate])
        command.append_arg('min_tx_rate', opts[:min_tx_rate])
        command.append_arg('spoofchk', opts[:spoofchk])
        command.append_arg('query_rss', opts[:query_rss])
        command.append_arg('state', opts[:state])
        command.append_arg('trust', opts[:trust])
        command.append_arg('node_guid', opts[:node_guid])
        command.append_arg('port_guid', opts[:port_guid])
      end
    end
  end
end
