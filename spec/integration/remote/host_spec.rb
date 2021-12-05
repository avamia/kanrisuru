# frozen_string_literal: true

require 'spec_helper'

TestHosts.each_os do |os_name, host_json|
  RSpec.describe Kanrisuru::Remote::Host do
    context "with #{os_name}" do
      let(:host) do
        described_class.new(
          host: host_json['hostname'],
          username: host_json['username'],
          keys: [host_json['ssh_key']]
        )
      end

      after do
        host.disconnect
      end

      it 'can ping localhost' do
        expect(host.ping?).to eq(true)
      end

      it 'gets hostname' do
        expect(host.hostname).to eq(host_json['hostname'])
      end

      it 'changes directories' do
        expect(host.pwd.path).to eq(host_json['home'])

        host.cd('../')
        expect(host.pwd.path).to eq('/home')

        host.cd('../')
        expect(host.pwd.path).to eq('/')

        host.cd('~')

        expect(host.pwd.path).to eq(host_json['home'])

        host.su('root')
        host.cd('/root/../etc')

        result = host.ls
        paths = result.map(&:path)

        expect(paths).to include('hosts')
        expect(paths).to include('shadow')
        expect(paths).to include('ssh')

        host.cd('default')
        expect(host.pwd.path).to eq('/etc/default')

        host.su(host_json['username'])

        host.cd('.')
        expect(host.pwd.path).to eq('/etc/default')

        result = host.ls(path: '/home')
        expect(result[0].path).to eq(host_json['username'])

        host.cd('/bin')
        expect(host.pwd.path).to eq('/bin')
      end
    end
  end
end
