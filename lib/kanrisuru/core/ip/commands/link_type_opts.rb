# frozen_string_literal: true

module Kanrisuru
  module Core
    module IP
      def ip_link_type_opts(command, opts)
        case opts[:type]
        when 'vlan'
          ip_link_vlan_opts(command, opts[:type_opts])
        when 'vxlan'
          ip_link_vxlan_opts(command, opts[:type_opts])
        when 'veth', 'vxcan'
          ip_link_veth_vxcan_opts(command, opts[:type_opts])
        when 'ipip', 'sit'
          ip_link_ipip_sit_opts(command, opts[:type_opts])
        when 'gre', 'gretap'
          ip_link_gre_gretap_opts(command, opts[:type_opts])
        when 'ip6gre', 'ip6gretap'
          ip_link_ip6gre_ip6gretap_opts(command, opts[:type_opts])
        when 'ipoib'
          ip_link_ipoib_opts(command, opts[:type_opts])
        when 'erspan', 'ip6erspan'
          ip_link_erspan_opts(command, opts[:type_opts])
        when 'geneve'
          ip_link_geneve_opts(command, opts[:type_opts])
        when 'bareudp'
          ip_link_bareudp_opts(command, opts[:type_opts])
        when 'macvlan', 'macvtap'
          ip_link_macvlan_macvtap_opts(command, opts[:type_opts])
        when 'hsr'
          ip_link_hsr_opts(command, opts[:type_opts])
        when 'bridge'
          ip_link_bridge_opts(command, opts[:type_opts])
        when 'macsec'
          ip_link_macsec_opts(command, opts[:type_opts])
        when 'vrf'
          ip_link_vrf_opts(command, opts[:type_opts])
        when 'rmnet'
          ip_link_rmnet_opts(command, opts[:type_opts])
        when 'xfrm'
          ip_link_xfrm_opts(command, opts[:type_opts])
        when 'bridge_slave'
          ip_link_bridge_slave_opts(command, opts[:type_opts])
        when 'bond_slave'
          ip_link_bond_slave_opts(command, opts[:type_opts])
        end
      end

      def ip_link_vlan_opts(command, opts)
        command.append_arg('protocol', opts[:protocol])
        command.append_arg('id', opts[:id])
        command.append_arg('reorder_hdr', opts[:reorder_hdr])
        command.append_arg('gvrp', opts[:gvrp])
        command.append_arg('mvrp', opts[:mvrp])
        command.append_arg('loose_binding', opts[:loose_binding])
        command.append_arg('bridge_binding', opts[:bridge_binding])
        command.append_arg('ingress-qos-map', opts[:ingress_qos_map])
        command.append_arg('egress-qos-map', opts[:egress_qos_map])
      end

      def ip_link_vxlan_opts(command, opts)
        command.append_arg('id', opts[:id])
        command.append_arg('dev', opts[:dev])
        command.append_arg('group', opts[:group])
        command.append_arg('remote', opts[:remote])
        command.append_arg('local', opts[:local])
        command.append_arg('ttl', opts[:ttl])
        command.append_arg('tos', opts[:tos])
        command.append_arg('df', opts[:df])
        command.append_arg('flowlabel', opts[:flowlabel])
        command.append_arg('dstport', opts[:dstport])
        command.append_arg('srcport', opts[:srcport])

        command.append_flag_no('learning', opts[:learning])
        command.append_flag_no('rsc', opts[:rsc])
        command.append_flag_no('proxy', opts[:proxy])
        command.append_flag_no('l2miss', opts[:l2miss])
        command.append_flag_no('l3miss', opts[:l3miss])
        command.append_flag_no('udpcsum', opts[:udpcsum])
        command.append_flag_no('udp6zerocsumtx', opts[:udp6zerocsumtx])
        command.append_flag_no('udp6zerocsumrx', opts[:udp6zerocsumrx])

        command.append_arg('ageing', opts[:ageing])
        command.append_arg('maxaddress', opts[:maxaddress])

        command.append_flag('gbp', opts[:gbp])
        command.append_flag('gpe', opts[:gpe])
      end

      def ip_link_veth_vxcan_opts(command, opts)
        command.append_arg('peer name', opts[:peer_name])
      end

      def ip_link_ipip_sit_opts(command, opts)
        ip_link_shared_sit_gre_opts(command, opts)
        command.append_arg('mode', opts[:mode])
      end

      def ip_link_gre_gretap_opts(command, opts)
        ip_link_shared_sit_gre_opts(command, opts)
        ip_link_shared_io_opts(command, opts)

        command.append_arg('ttl', opts[:ttl])
        command.append_arg('tos', opts[:tos])

        command.append_flag_no('pmtudisc', opts[:pmtudisc])
        command.append_flag_no('ignore-df', opts[:ignore_df])

        command.append_arg('dev', opts[:dev])
      end

      def ip_link_ip6gre_ip6gretap_opts(command, opts)
        command.append_arg('remote', opts[:remote])
        command.append_arg('local', opts[:local])
        ip_link_shared_io_opts(command, opts)

        command.append_arg('hoplimit', opts[:hoplimit])
        command.append_arg('encaplimit', opts[:encaplimit])
        command.append_arg('flowlabel', opts[:flowlabel])

        command.append_flag_no('allow-localremote', opts[:allow_localremote])
        command.append_arg('tclass', opts[:tclass])
        command.append_arg('external', opts[:external])
      end

      def ip_link_ipoib_opts(command, opts)
        command.append_arg('pkey', opts[:pkey])
        command.append_arg('mode', opts[:mode])
      end

      def ip_link_erspan_opts(command, opts)
        command.append_arg('remote', opts[:remote])
        command.append_arg('local', opts[:local])
        command.append_arg('erspan_ver', opts[:erspan_ver])
        command.append_arg('erspan', opts[:erspan])
        command.append_arg('erspan_dir', opts[:erspan_dir])
        command.append_arg('erspan_hwid', opts[:erspan_hwid])
        command.append_flag_no('allow-localremote', opts[:allow_localremote])
        command.append_flag('external', opts[:external])
      end

      def ip_link_geneve_opts(command, opts)
        command.append_arg('id', opts[:id])
        command.append_arg('remote', opts[:remote])
        command.append_arg('ttl', opts[:ttl])
        command.append_arg('tos', opts[:tos])
        command.append_arg('df', opts[:df])
        command.append_arg('flowlabel', opts[:flowlabel])
        command.append_arg('dstport', opts[:dstport])

        command.append_flag_no('external', opts[:external])
        command.append_flag_no('udpcsum', opts[:udpcsum])
        command.append_flag_no('udp6zerocsumtx', opts[:udp6zerocsumtx])
        command.append_flag_no('udp6zerocsumrx', opts[:udp6zerocsumrx])
      end

      def ip_link_bareudp_opts(command, opts)
        command.append_arg('dstport', opts[:dstport])
        command.append_arg('ethertype', opts[:ethertype])
        command.append_arg('srcportmin', opts[:srcportmin])
        command.append_flag_no('multiproto', opts[:multiproto])
      end

      def ip_link_macvlan_macvtap_opts(command, opts)
        command.append_arg('mode', opts[:mode])
        command.append_arg('flag', opts[:flag])

        case opts[:mode_opts]
        when 'add', 'del'
          command << opts[:mode_opts]
          command << opts[:mac_address]
        when 'set'
          command << 'set'
          command.append_array(opts[:mac_address])
        when 'flush'
          command << 'flush'
        end
      end

      def ip_link_hsr_opts(command, opts)
        command.append_arg('slave1', opts[:slave1])
        command.append_arg('slave2', opts[:slave2])
        command.append_arg('supervision', opts[:supervision])
        command.append_arg('version', opts[:version])
        command.append_arg('proto', opts[:proto])
      end

      def ip_link_bridge_opts(command, opts)
        command.append_arg('ageing_time', opts[:ageing_time])
        command.append_arg('group_fwd_mask', opts[:group_fwd_mask])
        command.append_arg('group_address', opts[:group_address])
        command.append_arg('forward_delay', opts[:forward_delay])
        command.append_arg('hello_time', opts[:hello_time])
        command.append_arg('max_age', opts[:max_age])
        command.append_arg('stp_state', opts[:stp_state])
        command.append_arg('priority', opts[:priority])
        command.append_arg('vlan_filtering', opts[:vlan_filtering])
        command.append_arg('vlan_protocol', opts[:vlan_protocol])
        command.append_arg('vlan_default_pvid', opts[:vlan_default_pvid])
        command.append_arg('vlan_stats_enabled', opts[:vlan_stats_enabled])
        command.append_arg('vlan_stats_per_port', opts[:vlan_stats_per_port])
        command.append_arg('mcast_snooping', opts[:mcast_snooping])
        command.append_arg('mcast_router', opts[:mcast_router])
        command.append_arg('mcast_query_use_ifaddr', opts[:mcast_query_use_ifaddr])
        command.append_arg('mcast_querier', opts[:mcast_querier])
        command.append_arg('mcast_querier_interval', opts[:mcast_querier_interval])
        command.append_arg('mcast_hash_elasticity', opts[:mcast_hash_elasticity])
        command.append_arg('mcast_hash_max', opts[:mcast_hash_max])
        command.append_arg('mcast_last_member_count', opts[:mcast_last_member_count])
        command.append_arg('mcast_last_member_interval', opts[:mcast_last_member_interval])
        command.append_arg('mcast_startup_query_count', opts[:mcast_startup_query_count])
        command.append_arg('mcast_startup_query_interval', opts[:mcast_startup_query_interval])
        command.append_arg('mcast_query_interval', opts[:mcast_query_interval])
        command.append_arg('mcast_query_response_interval', opts[:mcast_query_response_interval])
        command.append_arg('mcast_membership_interval', opts[:mcast_membership_interval])
        command.append_arg('mcast_stats_enabled', opts[:mcast_stats_enabled])
        command.append_arg('mcast_igmp_version', opts[:mcast_igmp_version])
        command.append_arg('mcast_mld_version', opts[:mcast_mld_version])
        command.append_arg('nf_call_iptables', opts[:nf_call_iptables])
        command.append_arg('nf_call_ip6tables', opts[:nf_call_ip6tables])
        command.append_arg('nf_call_arptables', opts[:nf_call_arptables])
      end

      def ip_link_macsec_opts(command, opts)
        command.append_arg('address', opts[:address])
        command.append_arg('port', opts[:port])
        command.append_arg('sci', opts[:sci])
        command.append_arg('cipher', opts[:cipher])
        command.append_arg('icvlen', opts[:icvlen])
        command.append_arg('encrypt', opts[:encrypt])
        command.append_arg('send_sci', opts[:send_sci])
        command.append_arg('end_station', opts[:end_station])
        command.append_arg('scb', opts[:scb])
        command.append_arg('protect', opts[:protect])
        command.append_arg('replay', opts[:replay])
        command.append_arg('window', opts[:window])
        command.append_arg('validate', opts[:validate])
        command.append_arg('encodingsa', opts[:encodingsa])
      end

      def ip_link_vrf_opts(command, opts)
        command.append_arg('table', opts[:table])
      end

      def ip_link_rmnet_opts(command, opts)
        command.append_arg('mux_id', opts[:mux_id])
      end

      def ip_link_xfrm_opts(command, opts)
        command.append_arg('if_id', opts[:if_id])
      end

      def ip_link_bridge_slave_opts(command, opts)
        command.append_flag('fdb_flush', opts[:fdb_flush])
        command.append_arg('state', opts[:state])
        command.append_arg('priority', opts[:priority])
        command.append_arg('cost', opts[:cost])
        command.append_arg('guard', opts[:guard])
        command.append_arg('hairpin', opts[:hairpin])
        command.append_arg('fastleave', opts[:fastleave])
        command.append_arg('root_block', opts[:root_block])
        command.append_arg('learning', opts[:learning])
        command.append_arg('flood', opts[:flood])
        command.append_arg('proxy_arp', opts[:proxy_arp])
        command.append_arg('proxy_arp_wifi', opts[:proxy_arp_wifi])
        command.append_arg('mcast_router', opts[:mcast_router])
        command.append_arg('mcast_fast_leave', opts[:mcast_fast_leave])
        command.append_arg('mcast_flood', opts[:mcast_flood])
        command.append_arg('mcast_to_unicast', opts[:mcast_to_unicast])
        command.append_arg('group_fwd_mask', opts[:group_fwd_mask])
        command.append_arg('neigh_suppress', opts[:neigh_suppress])
        command.append_arg('neigh_suppress', opts[:neigh_suppress])
        command.append_arg('backup_port', opts[:backup_port])
        command.append_flag('nobackup_port', opts[:nobackup_port])
      end

      def ip_link_bond_slave_opts(command, opts)
        command.append_arg('queue_id', opts[:queue_id])
      end

      def ip_link_shared_io_opts(command, opts)
        command.append_flag_no('iseq', opts[:iseq])
        command.append_flag_no('oseq', opts[:oseq])

        command.append_flag_no('icsum', opts[:icsum])
        command.append_flag_no('ocsum', opts[:ocsum])

        if opts[:okey] == false
          command.append_flag('nookey', opts[:okey])
        elsif opts[:okey].instance_of?(Integer)
          command.append_arg('okey', opts[:okey])
        end

        if opts[:ikey] == false
          command.append_flag('noikey', opts[:ikey])
        elsif opts[:ikey].instance_of?(Integer)
          command.append_arg('ikey', opts[:ikey])
        end
      end

      def ip_link_shared_sit_gre_opts(command, opts)
        command.append_arg('remote', opts[:remote])
        command.append_arg('local', opts[:local])
        command.append_arg('encap', opts[:encap])
        command.append_arg('encap-sport', opts[:encap_sport])

        command.append_flag_no('encap-csum', opts[:encap_csum])
        command.append_flag_no('encap-remcsum', opts[:encap_remcsum])
        command.append_flag('external', opts[:external])
      end
    end
  end
end
