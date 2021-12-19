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

  %w[route r ro rou rout].each do |object_variant|
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
            expect_command(host.ip(object_variant), 'ip -json route show')
            expect_command(host.ip(object_variant, {
                                     family: 'inet',
                                     to: '10.0/16',
                                     from: '10.1/16',
                                     dev: 'eno4',
                                     protocol: 'kernel',
                                     dsfield: '0x30',
                                     table: 'all',
                                     vrf: 'blue',
                                     cloned: true,
                                     cached: true,
                                     via: '10.0.0.1',
                                     src: '10.5.5.5',
                                     realms: '6'
                                   }), 'ip -json -family inet route show to 10.0/16 dev eno4 protocol kernel table all dsfield 0x30 via 10.0.0.1 vrf blue src 10.5.5.5 realms 6 cloned cached')
          end
        end
      end

      context 'without json support' do
        before(:all) do
          StubNetwork.stub_command!(:ip_version) do
            Kanrisuru::Core::IP::IPROUTE2_JSON_VERSION - 33
          end
        end

        after(:all) do
          StubNetwork.unstub_command!(:ip_version)
        end

        %w[show list].each do |action_variant|
          it "prepares #{action_variant} command" do
            expect_command(host.ip(object_variant), 'ip route show')
            expect_command(host.ip(object_variant, {
                                     family: 'inet',
                                     to: '10.0/16',
                                     from: '10.1/16',
                                     dev: 'eno4',
                                     protocol: 'kernel',
                                     dsfield: '0x30',
                                     table: 'all',
                                     vrf: 'blue',
                                     cloned: true,
                                     cached: true,
                                     via: '10.0.0.1',
                                     src: '10.5.5.5',
                                     realms: '6'
                                   }), 'ip -family inet route show to 10.0/16 dev eno4 protocol kernel table all dsfield 0x30 via 10.0.0.1 vrf blue src 10.5.5.5 realms 6 cloned cached')
          end
        end
      end

      %w[add change append del delete replace].each do |action_variant|
        it "prepares #{action_variant} command" do
          expect_command(host.ip(object_variant, action_variant, {
                                   dev: 'eno2',
                                   mtu: 1600,
                                   congctl: 'test'
                                 }), "ip route #{action_variant} dev eno2 mtu 1600 congctl test")

          expect_command(host.ip(object_variant, action_variant, {
                                   to: '0/0',
                                   tos: '0x28',
                                   dsfield: '0x98',
                                   metric: 32,
                                   table: 254,
                                   vrf: 'green',
                                   src: '172.3.3.3',
                                   realm: '6',
                                   mtu: 1600,
                                   mtu_lock: true,
                                   window: 3,
                                   rtt: 4,
                                   rttvar: 12,
                                   rto_min: 1,
                                   sshthresh: 0,
                                   cwnd: 12,
                                   initcwnd: 5,
                                   initrwnd: 5,
                                   features: 'ecn',
                                   quickack: 'true',
                                   fastopen_no_cookie: 'true',
                                   congctl: 'test',
                                   congctl_lock: true,
                                   advmss: 7,
                                   reordering: 3,
                                   next_hop: {
                                     via: '172.0.0.0',
                                     dev: 'gateway',
                                     weight: 100
                                   },
                                   scope: 0,
                                   protocol: 'static',
                                   onlink: true,
                                   pref: 'high'
                                 }), "ip route #{action_variant} to 0/0 tos 0x28 dsfield 0x98 metric 32 table 254 vrf green src 172.3.3.3 realm 6 mtu lock 1600 window 3 rtt 4 rttvar 12 rto_min 1 cwnd 12 initcwnd 5 initrwnd 5 features ecn quickack true fastopen_no_cookie true congctl lock test advmss 7 reordering 3 next_hop via 172.0.0.0 dev gateway weight 100 scope 0 protocol static onlink pref high")
        end
      end

      it 'prepares flush command' do
        expect_command(host.ip(object_variant, 'flush', {
                                 family: 'inet',
                                 to: '10.0/16',
                                 from: '10.1/16',
                                 dev: 'eno4',
                                 protocol: 'kernel',
                                 dsfield: '0x30',
                                 table: 'all',
                                 vrf: 'blue',
                                 cloned: true,
                                 cached: true,
                                 via: '10.0.0.1',
                                 src: '10.5.5.5',
                                 realms: '6'
                               }), 'ip -family inet route flush to 10.0/16 dev eno4 protocol kernel table all dsfield 0x30 via 10.0.0.1 vrf blue src 10.5.5.5 realms 6 cloned cached')
      end

      it 'prepares get command' do
        expect_command(host.ip(object_variant, 'get', {
                                 dev: 'eth1',
                                 to: '10.0/16',
                                 from: '10.1/16',
                                 fibmatch: true,
                                 tos: '0x28',
                                 dsfield: '0x30',
                                 iif: 'eth0',
                                 oif: 'eth1',
                                 mark: '0x20',
                                 ipproto: 'tcp',
                                 dport: 80,
                                 sport: 80,
                                 connected: true
                               }), 'ip route get fibmatch to 10.0/16 from 10.1/16 tos 0x28 dsfield 0x30 iif eth0 oif eth1 mark 0x20 ipproto tcp sport 80 dport 80 connected')
      end
    end
  end
end
