# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Find do
  TestHosts.each_os do |os_name|
    context "with #{os_name}" do
      let(:host_json) { TestHosts.host(os_name) }
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

      it 'finds home directory' do
        result = host.find(paths: '/home')
        home = result.find { |item| item.path == host_json['home'] }
        expect(home.path).to eq(host_json['home'])

        result = host.find(paths: ['/home'])
        home = result.find { |item| item.path == host_json['home'] }
        expect(home.path).to eq(host_json['home'])
      end

      it 'finds /etc/hosts file' do
        host.su('root')
        result = host.find(paths: '/etc', type: 'file', name: 'hosts', uid: 0, gid: 0, writeable: true, maxdepth: 1)
        expect(result[0].path).to eq('/etc/hosts')

        file = host.stat(result[0].path)
        expect(file.uid).to eq(0)
        expect(file.gid).to eq(0)
      end

      it 'finds files with regex' do
        result = host.find(paths: '~', regex: '.*.\\(js\\|rb\\)')
        expect(result.data).to be_instance_of(Array)
      end

      it 'finds files by size' do
        result = host.find(paths: '~', size: '+2M', type: 'file')
        expect(result.data).to be_instance_of(Array)
      end
    end
  end
end
