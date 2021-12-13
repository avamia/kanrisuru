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

  %w[maddress maddr m].each do |object_variant|
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
            expect_command(host.ip(object_variant, action_variant), 'ip -json maddress show')
            expect_command(host.ip(object_variant, action_variant, {
                                     dev: 'eth0',
                                     family: 'inet'
                                   }), 'ip -json -family inet maddress show dev eth0')
          end
        end
      end

      context 'without json support' do
        before(:all) do
          StubNetwork.stub_command!(:ip_version) do
            Kanrisuru::Core::IP::IPROUTE2_JSON_VERSION - 23
          end
        end

        after(:all) do
          StubNetwork.unstub_command!(:ip_version)
        end

        %w[show list].each do |action_variant|
          it "prepares #{action_variant} command" do
            expect_command(host.ip(object_variant, action_variant), 'ip maddress show')
            expect_command(host.ip(object_variant, action_variant, {
                                     dev: 'eth0',
                                     family: 'inet'
                                   }), 'ip -family inet maddress show dev eth0')
          end
        end
      end

      %w[add delete del].each do |action_variant|
        it "prepares #{action_variant} command" do
          expect_command(host.ip(object_variant, action_variant, {
                                   address: '01:80:c2:00:00:0e',
                                   dev: 'eth0'
                                 }), "ip maddress #{action_variant} address 01:80:c2:00:00:0e dev eth0")
        end
      end
    end
  end
end
