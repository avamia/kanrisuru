# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'cluster' do |os_name, host_json, spec_dir|
  context "with #{os_name}" do
    let(:host1) do
      Kanrisuru::Remote::Host.new(
        host: host_json['hostname'],
        username: host_json['username'],
        keys: [host_json['ssh_key']]
      )
    end

    let(:host2) do
      Kanrisuru::Remote::Host.new(
        host: 'localhost',
        username: 'ubuntu',
        keys: ['~/.ssh/id_rsa']
      )
    end

    it 'gets hostname for cluster' do
      cluster = described_class.new({
                                      host: 'localhost',
                                      username: 'ubuntu',
                                      keys: ['~/.ssh/id_rsa']
                                    }, {
                                      host: '127.0.0.1',
                                      username: 'ubuntu',
                                      keys: ['~/.ssh/id_rsa']
                                    })

      expect(cluster.hostname).to match([
                                          { host: 'localhost', result: 'ubuntu' },
                                          { host: '127.0.0.1', result: 'ubuntu' }
                                        ])

      cluster.disconnect
    end

    it 'can ping host cluster' do
      cluster = described_class.new({
                                      host: 'localhost',
                                      username: 'ubuntu',
                                      keys: ['~/.ssh/id_rsa']
                                    }, {
                                      host: '127.0.0.1',
                                      username: 'ubuntu',
                                      keys: ['~/.ssh/id_rsa']
                                    })

      expect(cluster.ping?).to match([
                                       { host: 'localhost', result: true },
                                       { host: '127.0.0.1', result: true }
                                     ])

      cluster.disconnect
    end

    it 'disconnects all hosts' do
      cluster = described_class.new(host1, host2)
      cluster.disconnect

      cluster.each do |host|
        expect(host.ssh.closed).to be_truthy
      end
    end
  end
end
