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

  %w[addrlabel addrl].each do |object_variant|
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
            expect_command(host.ip(object_variant, action_variant), 'ip -json addrlabel list')
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
            expect_command(host.ip(object_variant, action_variant), 'ip addrlabel list')
          end
        end
      end

      it 'prepares flush command' do
        expect_command(host.ip(object_variant, 'flush'), 'ip addrlabel flush')
      end

      it 'prepares add command' do
        expect_command(host.ip(object_variant, 'add', {
                                 prefix: '0.0.0.0/96',
                                 dev: 'eno2',
                                 label: 'eno2'
                               }), 'ip addrlabel add prefix 0.0.0.0/96 dev eno2 label eno2')
      end

      it 'prepares del command' do
        expect_command(host.ip(object_variant, 'del', {
                                 prefix: '0.0.0.0/96',
                                 dev: 'eno2',
                                 label: 'eno2'
                               }), 'ip addrlabel del prefix 0.0.0.0/96 dev eno2 label eno2')
      end
    end
  end
end
