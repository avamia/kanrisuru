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

  %w[rule ru].each do |object_variant|
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
            expect_command(host.ip(object_variant, action_variant), 'ip -json rule show')
          end
        end

        %w[add delete del].each do |action_variant|
          it "prepares #{action_variant} command" do
            expect_command(host.ip(object_variant, action_variant, {
                                     type: 'unicast',
                                     from: '0/0',
                                     to: '0/0',
                                     iif: 'eth0',
                                     oif: 'eth1',
                                     tos: '0x28',
                                     dsfield: '0x30',
                                     fwmark: 2,
                                     uidrange: '1-10',
                                     ipproto: 'tcp',
                                     sport: 80,
                                     dport: 80,
                                     priority: 1,
                                     table: 5,
                                     protocol: 'kernel',
                                     suppress_prefixlength: 8,
                                     suppress_ifgroup: 6,
                                     realms: '1',
                                     nat: '10.1.1.1'
                                   }), "ip rule #{action_variant} type unicast from 0/0 to 0/0 iif eth0 tos 0x28 dsfield 0x30 fwmark 2 priority 1 table 5 realms 1 nat 10.1.1.1")
          end
        end

        it 'prepares flush command' do
          expect_command(host.ip(object_variant, 'flush', {
                                   protocol: 'kernel'
                                 }), 'ip rule flush protocol kernel')
        end
      end
    end
  end
end
