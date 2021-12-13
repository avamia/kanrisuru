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

  %w[address addr a].each do |object_variant|
    context "with ip #{object_variant}" do
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
          expect_command(host.ip(object_variant, action_variant), 'ip -json address show')
          expect_command(host.ip(object_variant, action_variant, {
                                   stats: true,
                                   family: 'inet',
                                   dev: 'lo',
                                   scope: 'host',
                                   prefix: '127.0.0.1',
                                   label: 'lo'
                                 }), 'ip -json -s -family inet address show dev lo scope host to 127.0.0.1 label lo')

          expect_command(host.ip(object_variant, action_variant, {
                                   dynamic: true,
                                   permanent: true,
                                   deprecated: true,
                                   primary: true,
                                   secondary: true,
                                   up: true
                                 }), 'ip -json address show dynamic permanent deprecated primary secondary up')
        end
      end

      it 'prepares add command' do
        expect_command(host.ip(object_variant, 'add', {
                                 address: '10.0.0.1',
                                 dev: 'eno1',
                                 label: 'eno1',
                                 scope: 'link'
                               }), 'ip address add 10.0.0.1 dev eno1 label eno1 scope link')
      end

      %w[del delete].each do |action_variant|
        it "prepares #{action_variant} command" do
          expect_command(host.ip(object_variant, action_variant, {
                                   address: '10.0.0.1',
                                   dev: 'eno1',
                                   label: 'eno1',
                                   scope: 'link'
                                 }), 'ip address del 10.0.0.1 dev eno1 label eno1 scope link')
        end
      end

      it 'prepares flush command' do
        expect_command(host.ip(object_variant, 'flush', {
                                 dev: 'eno1',
                                 scope: 'link',
                                 prefix: 'eno1',
                                 label: 'eno1'
                               }), 'ip address flush dev eno1 scope link to eno1 label eno1')

        expect_command(host.ip(object_variant, 'flush', {
                                 dynamic: true,
                                 permanent: true,
                                 deprecated: true,
                                 primary: true,
                                 secondary: true
                               }), 'ip address flush dynamic permanent deprecated primary secondary')
      end
    end
  end
end
