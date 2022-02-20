# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'host' do |os_name, host_json, _spec_dir|
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

    it 'connects with proxy host' do
      config = TestHosts.host('proxy')
      proxy = Kanrisuru::Remote::Host.new(
        host: config['hostname'],
        username: config['username'],
        keys: [config['ssh_key']]
      )

      expect(proxy).to be_ping

      host = Kanrisuru::Remote::Host.new(
        host: TestHosts.resolve(host_json['hostname']),
        username: host_json['username'],
        keys: [host_json['ssh_key']],
        proxy: proxy
      )

      ## Test instiation
      expect(host.proxy).to be_instance_of(Net::SSH::Gateway)
      expect(host.ssh).to be_instance_of(Net::SSH::Connection::Session)

      ## Test basic commands
      expect(host.hostname).to eq(host_json['hostname'])

      host.cd('../')
      expect(host.pwd.path).to eq('/home')

      expect(host.whoami.user).to eq(host_json['username'])
      host.su 'root'
      expect(host.whoami.user).to eq('root')

      ## Test download
      src_path = '/etc/hosts'
      result = host.download(src_path)
      expect(result).to be_instance_of(String)
      lines = result.split("\n")
      expect(lines.length).to be >= 1

      ## Test upload
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
