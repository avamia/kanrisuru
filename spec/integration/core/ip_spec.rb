# frozen_string_literal: true

require 'spec_helper'

TestHosts.each_os do |os_name, host_json|
  RSpec.describe Kanrisuru::Core::IP do
    context "with #{os_name}" do
      let(:host) do
        Kanrisuru::Remote::Host.new(
          host: host_json['hostname'],
          username: host_json['username'],
          keys: [host_json['ssh_key']]
        )
      end

      after do
        host.disconnect
      end

      describe 'ip address' do
        it 'show' do
          result = host.ip('address', 'show', stats: true)
          expect(result).to be_success
        end
      end

      describe 'ip link' do
        it 'show' do
          result = host.ip('link', 'show', stats: true)
          expect(result).to be_success
        end
      end

      describe 'ip addrlabel' do
        it 'list' do
          result = host.ip('addrlabel', 'list')
          expect(result).to be_success
        end
      end

      describe 'ip route' do
        it 'show' do
          result = host.ip('route', 'show')
          expect(result).to be_success
        end
      end

      describe 'ip rule' do
        it 'show' do
          result = host.ip('rule', 'show')
          expect(result).to be_success
        end
      end

      describe 'ip neighbour' do
        it 'show' do
          result = host.ip('neighbour', 'show', stats: true)
          expect(result).to be_success
        end
      end

      describe 'ip maddress' do
        it 'show' do
          result = host.ip('maddress', 'show')
          expect(result).to be_success
        end
      end
    end
  end
end
