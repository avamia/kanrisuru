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

  %w[neighbour neigh n].each do |object_variant|
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
            expect_command(host.ip(object_variant), 'ip -json neighbour show')
            expect_command(host.ip(object_variant, {
                                     stats: true,
                                     to: '10.10.10.10',
                                     dev: 'ens3',
                                     vrf: 'red',
                                     proxy: true,
                                     unused: true,
                                     nud: 'all'
                                   }), 'ip -json -s neighbour show to 10.10.10.10 dev ens3 nud all proxy unused')
          end
        end
      end

      context 'without json support' do
        before(:all) do
          StubNetwork.stub_command!(:ip_version) do
            Kanrisuru::Core::IP::IPROUTE2_JSON_VERSION - 10
          end
        end

        after(:all) do
          StubNetwork.unstub_command!(:ip_version)
        end

        %w[show list].each do |action_variant|
          it "prepares #{action_variant} command" do
            expect_command(host.ip(object_variant), 'ip neighbour show')
            expect_command(host.ip(object_variant, {
                                     stats: true,
                                     to: '10.10.10.10',
                                     dev: 'ens3',
                                     vrf: 'red',
                                     proxy: true,
                                     unused: true,
                                     nud: 'all'
                                   }), 'ip -s neighbour show to 10.10.10.10 dev ens3 nud all proxy unused')
          end
        end
      end

      %w[add change replace].each do |action_variant|
        it "prepares #{action_variant} command" do
          expect_command(host.ip(object_variant, action_variant, {
                                   to: '192.168.16.14',
                                   dev: 'eno1',
                                   proxy: true,
                                   router: true,
                                   extern_learn: true,
                                   permanent: true,
                                   nud: 'probe',
                                   lladdr: '17:39:D1:24:53:CF'
                                 }), "ip neighbour #{action_variant} to 192.168.16.14 dev eno1 lladdr 17:39:D1:24:53:CF nud probe proxy router extern_learn")
        end
      end

      %w[delete del].each do |action_variant|
        it "prepares #{action_variant} command" do
          expect_command(host.ip(object_variant, action_variant, {
                                   to: '192.168.16.14',
                                   dev: 'eno1',
                                   proxy: true,
                                   router: true,
                                   extern_learn: true,
                                   permanent: true
                                 }), "ip neighbour #{action_variant} to 192.168.16.14 dev eno1 proxy router extern_learn")
        end
      end

      it 'prepares flush command' do
        expect_command(host.ip(object_variant, 'flush', {
                                 stats: true,
                                 to: '10.10.10.10',
                                 dev: 'ens3',
                                 vrf: 'red',
                                 proxy: true,
                                 unused: true,
                                 nud: 'all'
                               }), 'ip -s neighbour flush to 10.10.10.10 dev ens3 nud all unused')
      end
    end
  end
end
