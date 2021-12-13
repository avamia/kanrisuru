# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::IP do
  before(:all) do
    StubNetwork.stub!
  end

  after(:all) do
    StubNetwork.unstub!
  end

  let(:host) do
    Kanrisuru::Remote::Host.new(
      host: 'localhost',
      username: 'ubuntu',
      keys: ['id_rsa']
    )
  end

  %w[link l].each do |object_variant|
    context "with ip #{object_variant}" do
      context 'with json support' do
        before(:all) do
          StubNetwork.stub_command!(:ip_version) do
            Kanrisuru::Core::IP::IPROUTE2_JSON_VERSION
          end
        end

        after(:all) do
          StubNetwork.unstub_command!(:ip_version)
        end

        %w[show list].each do |action_variant|
          it "prepares #{action_variant} command" do
            expect_command(host.ip(object_variant, action_variant), 'ip -json link show')
            expect_command(host.ip(object_variant, action_variant, {
                                     stats: true,
                                     family: 'inet',
                                     dev: 'eth0',
                                     up: true
                                   }), 'ip -json -s -family inet link show dev eth0 up')

            expect_command(host.ip(object_variant, action_variant, {
                                     dev: 'eth0.10',
                                     group: '0',
                                     master: 'eth0',
                                     vrf: 'red',
                                     type: 'vlan'
                                   }), 'ip -json link show dev eth0.10 group 0 master eth0 type vlan vrf red')
          end
        end
      end

      context 'without json support' do
        before(:all) do
          StubNetwork.stub_command!(:ip_version) do
            Kanrisuru::Core::IP::IPROUTE2_JSON_VERSION - 1
          end
        end

        after(:all) do
          StubNetwork.unstub_command!(:ip_version)
        end

        %w[show list].each do |action_variant|
          it "prepares #{action_variant} command" do
            expect_command(host.ip(object_variant, action_variant), 'ip link show')
            expect_command(host.ip(object_variant, action_variant, {
                                     stats: true,
                                     family: 'inet',
                                     dev: 'eth0',
                                     up: true
                                   }), 'ip -s -family inet link show dev eth0 up')

            expect_command(host.ip(object_variant, action_variant, {
                                     dev: 'eth0.10',
                                     group: '0',
                                     master: 'eth0',
                                     vrf: 'red',
                                     type: 'vlan'
                                   }), 'ip link show dev eth0.10 group 0 master eth0 type vlan vrf red')
          end
        end
      end

      %w[delete del].each do |action_variant|
        it "prepares #{action_variant} command" do
          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'eth2'
                                 }), 'ip link delete dev eth2')

          expect_command(host.ip(object_variant, action_variant, {
                                   group: '0'
                                 }), 'ip link delete group 0')

          expect_command(host.ip(object_variant, action_variant, {
                                   type: 'vxlan'
                                 }), 'ip link delete type vxlan')
        end
      end

      %w[add a].each do |action_variant|
        it "prepares #{action_variant} command" do
          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'eth0',
                                   name: 'eth0',
                                   mtu: 9000,
                                   index: 1,
                                   numttxqueues: 1000,
                                   numrxqueues: 1000,
                                   gso_max_size: 32,
                                   gso_max_segs: 64
                                 }), 'ip link add dev eth0 name eth0 mtu 9000 index 1 numrxqueues 1000 gso_max_size 32 gso_max_segs 64')
        end

        it "prepares #{action_variant} command with vlan" do
          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'eth0',
                                   name: 'eth0.10',
                                   type: 'vlan',
                                   type_opts: {
                                     id: 10,
                                     protocol: '802.1Q',
                                     reorder_hdr: 'off',
                                     gvrp: 'off',
                                     mvrp: 'on',
                                     loose_binding: 'on',
                                     ingress_qos_map: '1:2',
                                     egress_qos_map: '2:1'
                                   }
                                 }), 'ip link add dev eth0 name eth0.10 type vlan protocol 802.1Q id 10 reorder_hdr off gvrp off mvrp on loose_binding on ingress-qos-map 1:2 egress-qos-map 2:1')
        end

        it "prepares #{action_variant} command with vxlan" do
          expect_command(host.ip(object_variant, action_variant, {
                                   name: 'eth0.5',
                                   type: 'vxlan',
                                   type_opts: {
                                     id: 5,
                                     remote: '172.0.0.12',
                                     dev: 'eth0',
                                     local: '10.0.0.1',
                                     ttl: '300',
                                     tos: '0x28',
                                     df: 'set',
                                     flowlabel: 'vxlan-label',
                                     dstport: 6082,
                                     srcport: '6085 6086',
                                     learning: true,
                                     rsc: true,
                                     proxy: true,
                                     l2miss: true,
                                     l3miss: true,
                                     external: true,
                                     udpcsum: true,
                                     udp6zerocsumtx: true,
                                     udp6zerocsumrx: true,
                                     ageing: 3600,
                                     maxaddress: 128,
                                     gbp: true,
                                     gpe: true
                                   }
                                 }), 'ip link add name eth0.5 type vxlan id 5 dev eth0 remote 172.0.0.12 local 10.0.0.1 ttl 300 tos 0x28 df set flowlabel vxlan-label dstport 6082 srcport 6085 6086 learning rsc proxy l2miss l3miss udpcsum udp6zerocsumtx udp6zerocsumrx ageing 3600 maxaddress 128 gbp gpe')

          expect_command(host.ip(object_variant, action_variant, {
                                   name: 'eth0.5',
                                   type: 'vxlan',
                                   type_opts: {
                                     id: 5,
                                     remote: '172.0.0.12',
                                     dev: 'eth0',
                                     learning: false,
                                     rsc: false,
                                     proxy: false,
                                     l2miss: false,
                                     l3miss: false,
                                     external: false,
                                     udpcsum: false,
                                     udp6zerocsumtx: false,
                                     udp6zerocsumrx: false,
                                     gbp: false
                                   }
                                 }), 'ip link add name eth0.5 type vxlan id 5 dev eth0 remote 172.0.0.12 nolearning norsc noproxy nol2miss nol3miss noudpcsum noudp6zerocsumtx noudp6zerocsumrx')
        end

        it "prepares #{action_variant} command with veth" do
          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'eth0',
                                   name: 'eth0.10',
                                   type: 'veth',
                                   type_opts: {
                                     peer_name: 'veth-tunnel-connect'
                                   }
                                 }), 'ip link add dev eth0 name eth0.10 type veth peer name veth-tunnel-connect')
        end

        it "prepares #{action_variant} command with vxcan" do
          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'eth0',
                                   name: 'eth0.10',
                                   type: 'vxcan',
                                   type_opts: {
                                     peer_name: 'vxcan-tunnel-connect'
                                   }
                                 }), 'ip link add dev eth0 name eth0.10 type vxcan peer name vxcan-tunnel-connect')
        end

        %w[ipip sit].each do |type|
          it "prepares #{action_variant} command with #{type}" do
            expect_command(host.ip(object_variant, action_variant, {
                                     dev: 'eth0',
                                     name: 'eth0.10',
                                     type: type,
                                     type_opts: {
                                       remote: '172.0.0.1',
                                       local: '10.0.0.2',
                                       encap: 'gue',
                                       encap_support: 'auto',
                                       encap_csum: true,
                                       encap_remcsum: true,
                                       mode: 'any',
                                       external: true
                                     }
                                   }), "ip link add dev eth0 name eth0.10 type #{type} remote 172.0.0.1 local 10.0.0.2 encap gue encap-csum encap-remcsum external mode any")

            expect_command(host.ip(object_variant, action_variant, {
                                     dev: 'eth0',
                                     name: 'eth0.10',
                                     type: type,
                                     type_opts: {
                                       remote: '172.0.0.1',
                                       local: '10.0.0.2',
                                       encap: 'gue',
                                       encap_support: 'auto',
                                       encap_csum: false,
                                       encap_remcsum: false,
                                       mode: 'any'
                                     }
                                   }), "ip link add dev eth0 name eth0.10 type #{type} remote 172.0.0.1 local 10.0.0.2 encap gue noencap-csum noencap-remcsum mode any")
          end
        end

        %w[gre gretap].each do |type|
          it "prepares #{action_variant} command with #{type}" do
            expect_command(host.ip(object_variant, action_variant, {
                                     name: 'eth0.10',
                                     type: type,
                                     type_opts: {
                                       remote: '172.0.0.1',
                                       local: '10.0.0.2',
                                       iseq: true,
                                       oseq: true,
                                       icsum: true,
                                       ocsum: true,
                                       ikey: 10,
                                       okey: 10,
                                       ttl: 300,
                                       tos: '0x28',
                                       pmtudisc: true,
                                       ignore_df: true,
                                       dev: 'eth0',
                                       encap: 'none',
                                       encap_sport: 'auto',
                                       encap_csum: true,
                                       encap_remcsum: true,
                                       external: true
                                     }
                                   }), "ip link add name eth0.10 type #{type} remote 172.0.0.1 local 10.0.0.2 encap none encap-sport auto encap-csum encap-remcsum external iseq oseq icsum ocsum okey 10 ikey 10 ttl 300 tos 0x28 pmtudisc ignore-df dev eth0")

            expect_command(host.ip(object_variant, action_variant, {
                                     name: 'eth0.10',
                                     type: type,
                                     type_opts: {
                                       remote: '172.0.0.1',
                                       local: '10.0.0.2',
                                       iseq: false,
                                       oseq: false,
                                       icsum: false,
                                       ocsum: false,
                                       ikey: false,
                                       okey: false,
                                       tos: '0x28',
                                       pmtudisc: false,
                                       ignore_df: false,
                                       dev: 'eth0',
                                       encap: 'none',
                                       encap_sport: 'auto',
                                       encap_csum: false,
                                       encap_remcsum: false
                                     }
                                   }), "ip link add name eth0.10 type #{type} remote 172.0.0.1 local 10.0.0.2 encap none encap-sport auto noencap-csum noencap-remcsum noiseq nooseq noicsum noocsum tos 0x28 nopmtudisc noignore-df dev eth0")
          end
        end

        %w[ip6gre ip6gretap].each do |type|
          it "prepares #{action_variant} command with #{type}" do
            expect_command(host.ip(object_variant, action_variant, {
                                     dev: 'eth0',
                                     name: 'eth0.10',
                                     type: type,
                                     type_opts: {
                                       external: true
                                     }
                                   }), "ip link add dev eth0 name eth0.10 type #{type} external true")

            expect_command(host.ip(object_variant, action_variant, {
                                     dev: 'eth0',
                                     name: 'eth0.10',
                                     type: type,
                                     type_opts: {
                                       remote: '172.0.0.1',
                                       local: '10.0.0.3',
                                       iseq: true,
                                       oseq: true,
                                       icsum: true,
                                       ocsum: true,
                                       ikey: 10,
                                       okey: 10,
                                       hoplimit: 300,
                                       encaplimit: 5,
                                       flowlabel: 'gre-flow-label',
                                       allow_localremote: true,
                                       tclass: 'internet'
                                     }
                                   }), "ip link add dev eth0 name eth0.10 type #{type} remote 172.0.0.1 local 10.0.0.3 iseq oseq icsum ocsum okey 10 ikey 10 hoplimit 300 encaplimit 5 flowlabel gre-flow-label allow-localremote tclass internet")

            expect_command(host.ip(object_variant, action_variant, {
                                     dev: 'eth0',
                                     name: 'eth0.10',
                                     type: type,
                                     type_opts: {
                                       remote: '172.0.0.1',
                                       local: '10.0.0.3',
                                       iseq: false,
                                       oseq: false,
                                       icsum: false,
                                       ocsum: false,
                                       ikey: false,
                                       okey: false,
                                       allow_localremote: false
                                     }
                                   }), "ip link add dev eth0 name eth0.10 type #{type} remote 172.0.0.1 local 10.0.0.3 noiseq nooseq noicsum noocsum noallow-localremote")
          end
        end

        it "prepares #{action_variant} command with ipoib" do
          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'eth0',
                                   name: 'eth0.10',
                                   type: 'ipoib',
                                   type_opts: {
                                     pkey: '0x8003',
                                     mode: 'connected'
                                   }
                                 }), 'ip link add dev eth0 name eth0.10 type ipoib pkey 0x8003 mode connected')
        end

        it "prepares #{action_variant} command with erspan" do
          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'erspan1',
                                   name: 'erspan1',
                                   type: 'erspan',
                                   type_opts: {
                                     remote: '172.0.0.1',
                                     local: '10.0.0.4',
                                     erspan_ver: 2,
                                     erspan: '1',
                                     erspan_dir: 'ingress',
                                     erspan_hwid: '17',
                                     allow_localremote: true
                                   }
                                 }), 'ip link add dev erspan1 name erspan1 type erspan remote 172.0.0.1 local 10.0.0.4 erspan_ver 2 erspan 1 erspan_dir ingress erspan_hwid 17 allow-localremote')

          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'erspan2',
                                   name: 'erspan2',
                                   type: 'erspan',
                                   type_opts: {
                                     remote: '172.0.0.1',
                                     local: '10.0.0.4',
                                     allow_localremote: false
                                   }
                                 }), 'ip link add dev erspan2 name erspan2 type erspan remote 172.0.0.1 local 10.0.0.4 noallow-localremote')

          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'erspan3',
                                   name: 'erspan3',
                                   type: 'erspan',
                                   type_opts: {
                                     external: true
                                   }
                                 }), 'ip link add dev erspan3 name erspan3 type erspan external')
        end

        it "prepares #{action_variant} command with ip6erspan" do
          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'ip6erspan1',
                                   name: 'ip6erspan1',
                                   type: 'ip6erspan',
                                   type_opts: {
                                     remote: 'fc00:100::1',
                                     local: 'fc00:100::1',
                                     erspan_ver: 2,
                                     erspan: '1',
                                     erspan_dir: 'ingress',
                                     erspan_hwid: '17',
                                     allow_localremote: true
                                   }
                                 }), 'ip link add dev ip6erspan1 name ip6erspan1 type ip6erspan remote fc00:100::1 local fc00:100::1 erspan_ver 2 erspan 1 erspan_dir ingress erspan_hwid 17 allow-localremote')

          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'ip6erspan2',
                                   name: 'ip6erspan2',
                                   type: 'ip6erspan',
                                   type_opts: {
                                     remote: 'fc00:100::1',
                                     local: 'fc00:100::1',
                                     allow_localremote: false
                                   }
                                 }), 'ip link add dev ip6erspan2 name ip6erspan2 type ip6erspan remote fc00:100::1 local fc00:100::1 noallow-localremote')

          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'ip6erspan3',
                                   name: 'ip6erspan3',
                                   type: 'ip6erspan',
                                   type_opts: {
                                     external: true
                                   }
                                 }), 'ip link add dev ip6erspan3 name ip6erspan3 type ip6erspan external')
        end

        it "prepares #{action_variant} command with geneve" do
          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'eth0',
                                   name: 'geneve0',
                                   type: 'geneve',
                                   type_opts: {
                                     external: true
                                   }
                                 }), 'ip link add dev eth0 name geneve0 type geneve external')

          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'eth0',
                                   name: 'geneve0',
                                   type: 'geneve',
                                   type_opts: {
                                     external: false
                                   }
                                 }), 'ip link add dev eth0 name geneve0 type geneve noexternal')

          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'eth0',
                                   name: 'geneve0',
                                   type: 'geneve',
                                   type_opts: {
                                     id: 1,
                                     remote: '172.0.0.1',
                                     ttl: 300,
                                     tos: '0x28',
                                     df: 'unset',
                                     flowlabel: 'geneve-flow-label',
                                     dstport: 6082,
                                     udpcsum: true,
                                     udp6zerocsumtx: true,
                                     udp6zerocsumrx: true
                                   }
                                 }), 'ip link add dev eth0 name geneve0 type geneve id 1 remote 172.0.0.1 ttl 300 tos 0x28 df unset flowlabel geneve-flow-label dstport 6082 udpcsum udp6zerocsumtx udp6zerocsumrx')

          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'eth0',
                                   name: 'geneve0',
                                   type: 'geneve',
                                   type_opts: {
                                     id: 1,
                                     remote: '172.0.0.1',
                                     ttl: 300,
                                     tos: '0x28',
                                     df: 'unset',
                                     flowlabel: 'geneve-flow-label',
                                     dstport: 6082,
                                     udpcsum: false,
                                     udp6zerocsumtx: false,
                                     udp6zerocsumrx: false
                                   }
                                 }), 'ip link add dev eth0 name geneve0 type geneve id 1 remote 172.0.0.1 ttl 300 tos 0x28 df unset flowlabel geneve-flow-label dstport 6082 noudpcsum noudp6zerocsumtx noudp6zerocsumrx')
        end

        it "prepares #{action_variant} command with bareudp" do
          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'bareudp0',
                                   name: 'bareudp0',
                                   type: 'bareudp',
                                   type_opts: {
                                     dstport: 6635,
                                     ethertype: 'mpls_uc',
                                     srcportmin: 100,
                                     multiproto: true
                                   }
                                 }), 'ip link add dev bareudp0 name bareudp0 type bareudp dstport 6635 ethertype mpls_uc srcportmin 100 multiproto')
        end

        %w[macvlan macvtap].each do |type|
          it "prepares #{action_variant} command with #{type}" do
            expect_command(host.ip(object_variant, action_variant, {
                                     dev: 'bareudp0',
                                     name: 'bareudp0',
                                     type: type,
                                     type_opts: {
                                       mode: 'bridge'
                                     }
                                   }), "ip link add dev bareudp0 name bareudp0 type #{type} mode bridge")
          end
        end

        it "prepares #{action_variant} command with hsr" do
          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'hsr1',
                                   name: 'hsr1',
                                   type: 'hsr',
                                   type_opts: {
                                     slave1: 'eth1',
                                     slave2: 'eth2',
                                     supervision: '254',
                                     version: '1',
                                     proto: '1'
                                   }
                                 }), 'ip link add dev hsr1 name hsr1 type hsr slave1 eth1 slave2 eth2 supervision 254 version 1 proto 1')
        end

        it "prepares #{action_variant} command with bridge" do
          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'br0',
                                   name: 'br0',
                                   type: 'bridge',
                                   type_opts: {
                                     ageing_time: 29_999,
                                     group_fwd_mask: 0,
                                     group_address: '01:80:c2:00:00:00',
                                     forward_delay: 0,
                                     hello_time: 199,
                                     max_age: 1999,
                                     stp_state: 0,
                                     priority: 32_768,
                                     vlan_filtering: 0,
                                     vlan_protocol: '802.1Q',
                                     vlan_default_pvid: 1,
                                     vlan_stats_enabled: 1,
                                     vlan_stats_per_port: 1,
                                     mcast_snooping: 1,
                                     mcast_router: 1,
                                     mcast_query_use_ifaddr: 0,
                                     mcast_querier: 0,
                                     mcast_hash_elasticity: 4,
                                     mcast_hash_max: 512,
                                     mcast_last_member_count: 2,
                                     mcast_startup_query_count: 2,
                                     mcast_last_member_interval: 99,
                                     mcast_membership_interval: 25_999,
                                     mcast_querier_interval: 25_499,
                                     mcast_query_interval: 12_499,
                                     mcast_query_response_interval: 999,
                                     mcast_startup_query_interval: 3124,
                                     mcast_stats_enabled: 0,
                                     mcast_igmp_version: 2,
                                     mcast_mld_version: 1,
                                     nf_call_iptables: 0,
                                     nf_call_ip6tables: 0,
                                     nf_call_arptables: 0
                                   }
                                 }), 'ip link add dev br0 name br0 type bridge ageing_time 29999 group_fwd_mask 0 group_address 01:80:c2:00:00:00 forward_delay 0 hello_time 199 max_age 1999 stp_state 0 priority 32768 vlan_filtering 0 vlan_protocol 802.1Q vlan_default_pvid 1 vlan_stats_enabled 1 vlan_stats_per_port 1 mcast_snooping 1 mcast_router 1 mcast_query_use_ifaddr 0 mcast_querier 0 mcast_querier_interval 25499 mcast_hash_elasticity 4 mcast_hash_max 512 mcast_last_member_count 2 mcast_last_member_interval 99 mcast_startup_query_count 2 mcast_startup_query_interval 3124 mcast_query_interval 12499 mcast_query_response_interval 999 mcast_membership_interval 25999 mcast_stats_enabled 0 mcast_igmp_version 2 mcast_mld_version 1 nf_call_iptables 0 nf_call_ip6tables 0 nf_call_arptables 0')
        end

        it "prepares #{action_variant} command with macsec" do
          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'eth0',
                                   name: 'macsec0',
                                   type: 'macsec',
                                   type_opts: {
                                     address: '32:53:41:bd:7c:27',
                                     port: 11,
                                     send_sci: 'on',
                                     sci: '1',
                                     cipher: 'GCM-AES-128',
                                     icvlen: 16,
                                     encrypt: 'on',
                                     end_station: 'on',
                                     scb: 'on',
                                     protect: 'on',
                                     replay: 'on',
                                     window: 1,
                                     validate: 'check',
                                     encodingsa: '3'
                                   }
                                 }), 'ip link add dev eth0 name macsec0 type macsec address 32:53:41:bd:7c:27 port 11 sci 1 cipher GCM-AES-128 icvlen 16 encrypt on send_sci on end_station on scb on protect on replay on window 1 validate check encodingsa 3')
        end

        it "prepares #{action_variant} command with vrf" do
          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'vrf1',
                                   name: 'vrf1',
                                   type: 'vrf',
                                   type_opts: {
                                     table: 10
                                   }
                                 }), 'ip link add dev vrf1 name vrf1 type vrf table 10')
        end

        it "prepares #{action_variant} command with rmnet" do
          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'rmnet0',
                                   name: 'rmnet0',
                                   type: 'rmnet',
                                   type_opts: {
                                     mux_id: 254
                                   }
                                 }), 'ip link add dev rmnet0 name rmnet0 type rmnet mux_id 254')
        end

        it "prepares #{action_variant} command with xfrm" do
          expect_command(host.ip(object_variant, action_variant, {
                                   name: 'xfrm3',
                                   type: 'xfrm',
                                   type_opts: {
                                     dev: 'xfrm3',
                                     if_id: 0
                                   }
                                 }), 'ip link add name xfrm3 type xfrm if_id 0')
        end
      end

      it 'prepares set command' do
        expect_command(host.ip(object_variant, 'set', {
                                 dev: 'eth10.10',
                                 direction: 'down'
                               }), 'ip link set dev eth10.10 down')

        expect_command(host.ip(object_variant, 'set', {
                                 dev: 'eno1.10',
                                 mtu: 1400,
                                 direction: 'up',
                                 arp: 'on',
                                 multicast: 'on',
                                 allmulticast: 'on',
                                 promisc: 'on',
                                 trailers: 'on',
                                 protodown: 'on',
                                 protodown_reason: 30,
                                 dynamic: 'on',
                                 name: 'eno1-vlan.10',
                                 txqueuelen: 256,
                                 txqlen: 4,
                                 master: 'eno1',
                                 address: '172.16.0.2',
                                 broadcast: 'ff:ff:ff:ff:ff:ff',
                                 brd: 'ff:ff:ff:ff:ff:ff',
                                 peer: 'ae:14:7e:e4:6c:64',
                                 netns: 1154,
                                 alias: 'eno1-alias',
                                 group: 0
                               }), 'ip link set dev eno1.10 group 0 up arp on multicast on allmulticast on promisc on protodown on protodown_reason 30 dynamic on name eno1-vlan.10 txqueuelen 256 txqlen 4 mtu 1400 address 172.16.0.2 broadcast ff:ff:ff:ff:ff:ff brd ff:ff:ff:ff:ff:ff peer ae:14:7e:e4:6c:64 netns 1154 alias eno1-alias master eno1')

        expect_command(host.ip(object_variant, 'set', {
                                 dev: 'eno1.10',
                                 master: false
                               }), 'ip link set dev eno1.10 nomaster')

        expect do
          host.ip(object_variant, 'set')
        end.to raise_error(ArgumentError)
      end

      it 'prepares set command with vf' do
        expect_command(host.ip(object_variant, 'set', {
                                 dev: 'eth0',
                                 vf: 5,
                                 mac: 'AD:D9:01:ED:0B:13',
                                 vlan: 10,
                                 qos: 1,
                                 proto: '802.1ad',
                                 rate: 0,
                                 max_tx_rate: 0,
                                 min_tx_rate: 0,
                                 spoofchk: 'on',
                                 query_rss: 'on',
                                 state: 'enable',
                                 trust: 'on',
                                 node_guid: 100,
                                 port_guid: 100
                               }), 'ip link set dev eth0 vf 5 mac AD:D9:01:ED:0B:13 vlan 10 qos 1 proto 802.1ad rate 0 max_tx_rate 0 min_tx_rate 0 spoofchk on query_rss on state enable trust on node_guid 100 port_guid 100')
      end

      it 'prepares set command with xdp' do
        expect_command(host.ip(object_variant, 'set', {
                                 dev: 'vethcaf7146',
                                 xdp: 'object',
                                 object: 'udp.o',
                                 section: 'dropper_main',
                                 verbose: true
                               }), 'ip link set dev vethcaf7146 xdp object udp.o section dropper_main verbose')

        expect_command(host.ip(object_variant, 'set', {
                                 dev: 'vethcaf7146',
                                 xdp: 'pinned',
                                 pinned: 'udp.o'
                               }), 'ip link set dev vethcaf7146 xdp pinned udp.o')

        expect_command(host.ip(object_variant, 'set', {
                                 dev: 'vethcaf7146',
                                 xdp: 'off'
                               }), 'ip link set dev vethcaf7146 xdp off')
      end

      it 'prepares set command with type opts' do
        expect do
          host.ip(object_variant, 'set', {
                    dev: 'eno10.10',
                    type: 'bridge_'
                  })
        end.to raise_error(ArgumentError)

        expect_command(host.ip(object_variant, 'set', {
                                 dev: 'eth0bridge',
                                 type: 'bridge_slave',
                                 type_opts: {
                                   fdb_flush: true,
                                   state: 1,
                                   priority: 63,
                                   cost: 1,
                                   guard: 'on',
                                   hairpin: 'off',
                                   fastleave: 'off',
                                   root_block: 'on',
                                   learning: 'on',
                                   flood: 'on',
                                   proxy_arp: 'on',
                                   proxy_arp_wifi: 'off',
                                   mcast_router: 3,
                                   mcast_fast_leave: 'on',
                                   mcast_flood: 'on',
                                   mcast_to_unicast: 'off',
                                   group_fwd_mask: 0,
                                   neigh_suppress: 'on',
                                   vlan_tunnel: 'on',
                                   backup_port: 'eth0backup'
                                 }
                               }), 'ip link set dev eth0bridge type bridge_slave fdb_flush state 1 priority 63 cost 1 guard on hairpin off fastleave off root_block on learning on flood on proxy_arp on proxy_arp_wifi off mcast_router 3 mcast_fast_leave on mcast_flood on mcast_to_unicast off group_fwd_mask 0 neigh_suppress on neigh_suppress on backup_port eth0backup')

        expect_command(host.ip(object_variant, 'set', {
                                 dev: 'eth0bridge',
                                 type: 'bridge_slave',
                                 type_opts: {
                                   nobackup_port: true
                                 }
                               }), 'ip link set dev eth0bridge type bridge_slave nobackup_port')

        expect_command(host.ip(object_variant, 'set', {
                                 dev: 'eth0bond',
                                 type: 'bond_slave',
                                 type_opts: {
                                   queue_id: 1
                                 }
                               }), 'ip link set dev eth0bond type bond_slave queue_id 1')

        expect_command(host.ip(object_variant, 'set', {
                                 dev: 'eth1macvlan',
                                 type: 'macvlan',
                                 type_opts: {
                                   mode: 'bridge',
                                   flag: 'nopromisc',
                                   mode_opts: 'add',
                                   mac_address: '19:18:4F:92:5E:CD'
                                 }
                               }), 'ip link set dev eth1macvlan type macvlan mode bridge flag nopromisc add 19:18:4F:92:5E:CD')

        expect_command(host.ip(object_variant, 'set', {
                                 dev: 'eth1macvlan',
                                 type: 'macvlan',
                                 type_opts: {
                                   mode_opts: 'del',
                                   mac_address: '19:18:4F:92:5E:CD'
                                 }
                               }), 'ip link set dev eth1macvlan type macvlan del 19:18:4F:92:5E:CD')

        expect_command(host.ip(object_variant, 'set', {
                                 dev: 'eth1macvlan',
                                 type: 'macvlan',
                                 type_opts: {
                                   mode_opts: 'set',
                                   mac_address: '07:88:8C:11:C3:80'
                                 }
                               }), 'ip link set dev eth1macvlan type macvlan set 07:88:8C:11:C3:80')

        expect_command(host.ip(object_variant, 'set', {
                                 dev: 'eth1macvlan',
                                 type: 'macvtap',
                                 type_opts: {
                                   mode_opts: 'set',
                                   mac_address: ['0D:42:6D:3E:22:B8', '7F:3D:FC:AF:A3:F3']
                                 }
                               }), 'ip link set dev eth1macvlan type macvtap set 0D:42:6D:3E:22:B8 7F:3D:FC:AF:A3:F3')

        expect_command(host.ip(object_variant, 'set', {
                                 dev: 'eth1macvlan',
                                 type: 'macvlan',
                                 type_opts: {
                                   mode_opts: 'flush'
                                 }
                               }), 'ip link set dev eth1macvlan type macvlan flush')
      end
    end
  end
end
