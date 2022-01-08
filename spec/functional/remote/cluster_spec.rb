# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Remote::Cluster do
  before(:all) do
    StubNetwork.stub!
  end

  after(:all) do
    StubNetwork.unstub!
  end

  let(:host1) do
    Kanrisuru::Remote::Host.new(
      host: 'localhost',
      username: 'ubuntu',
      keys: ['id_rsa']
    )
  end

  let(:host2) do
    Kanrisuru::Remote::Host.new(
      host: 'ubuntu-host',
      username: 'ubuntu',
      keys: ['id_rsa']
    )
  end

  it 'adds host to a cluster' do
    cluster = described_class.new(host1)
    expect(cluster.hosts.length).to eq(1)
    expect(cluster.count).to eq(1)
    expect(cluster[host1.host]).to eq(host1)
    expect(cluster.hosts).to include(host1)

    cluster << host2
    expect(cluster.hosts.length).to eq(2)
    expect(cluster.count).to eq(2)
    expect(cluster[host2.host]).to eq(host2)
    expect(cluster.hosts).to include(host1)
    expect(cluster.hosts).to include(host2)

    cluster << {
      host: 'centos-host',
      username: 'centos',
      keys: ['id_rsa']
    }

    expect(cluster.hosts.length).to eq(3)
    expect(cluster.count).to eq(3)
    expect(cluster.count).to eq(3)
    expect(cluster['centos-host'].username).to eq('centos')
    expect(cluster.hosts).to include(host1)
    expect(cluster.hosts).to include(host2)
  end

  it 'fails to add host to a cluster' do
    cluster = described_class.new
    expect { cluster << 1 }.to raise_error(ArgumentError)
    expect { cluster << 'hello' }.to raise_error(ArgumentError)
    expect { cluster << ['host'] }.to raise_error(ArgumentError)

    expect(cluster.count).to eq(0)
  end

  it 'creates a new command instance' do
    cluster = described_class.new
    cluster << host1
    cluster << host2

    expect(cluster.send(:create_command, 'hello')).to be_instance_of(Kanrisuru::Command)

    command = Kanrisuru::Command.new('ls')
    command.remote_user = 'root'
    command.remote_shell = '/bin/bash'
    cloned_command = cluster.send(:create_command, command)

    expect(cloned_command).to be_instance_of(Kanrisuru::Command)
    expect(cloned_command.object_id).not_to eq(command.object_id)

    expect(command.raw_command).to eq('ls')
    expect(cloned_command.raw_command).to eq('ls')

    expect(command.prepared_command).to eq('sudo -u root /bin/bash -c "ls"')
    expect(cloned_command.prepared_command).to eq('sudo -u root /bin/bash -c "ls"')

    expect do
      cluster.send(:create_command, 1)
    end.to raise_error(ArgumentError)
  end

  it 'runs execute for a command on a cluster' do
    cluster = described_class.new
    cluster << host1
    cluster << host2

    command = Kanrisuru::Command.new('pwd')

    results = cluster.execute(command)
    results.each do |result|
      expect(result).to have_key(:host)
      expect(result).to have_key(:result)
    end
  end

  it 'runs execute_shell for a command on a cluster' do
    cluster = described_class.new
    cluster << host1
    cluster << host2

    command = Kanrisuru::Command.new('pwd')
    command.remote_user = 'root'
    command.remote_shell = '/bin/zsh'

    results = cluster.execute_shell(command)
    results.each do |result|
      expect(result).to have_key(:host)
      expect(result).to have_key(:result)
    end
  end

  it 'removes a host from a cluster' do
    cluster = described_class.new(host1, host2)
    expect(cluster.count).to eq(2)

    cluster.delete(host2)
    expect(cluster.count).to eq(1)
    expect(cluster.hosts).not_to include(host2)

    cluster.delete(host1.host)
    expect(cluster.count).to eq(0)
    expect(cluster.hosts).not_to include(host1)
  end

  it 'fetches the hostname for each host in a cluster' do
    allow_any_instance_of(Kanrisuru::Remote::Host).to receive(:hostname).and_return('ubuntu')
    cluster = described_class.new(host1, host2)

    results = cluster.hostname
    results.each do |result|
      expect(result).to have_key(:host)
      expect(result).to have_key(:result)
      expect(result[:result]).to eq('ubuntu')
    end
  end

  it 'pings the host for each host in a cluster' do
    allow_any_instance_of(Kanrisuru::Remote::Host).to receive(:ping?).and_return(true)
    cluster = described_class.new(host1, host2)

    results = cluster.ping?
    results.each do |result|
      expect(result).to have_key(:host)
      expect(result).to have_key(:result)
      expect(result[:result]).to eq(true)
    end
  end

  it 'switches user for each host in a cluster' do
    cluster = described_class.new(host1, host2)

    cluster.su('root')
    cluster.each do |host|
      expect(host.remote_user).to eq('root')
    end
  end

  it 'changes current working directory for each host in a cluster' do
    cluster = described_class.new(host1, host2)

    StubNetwork.stub_command!(:pwd) do
      Kanrisuru::Core::Path::FilePath.new('/etc')
    end
    StubNetwork.stub_command!(:realpath) do
      Kanrisuru::Core::Path::FilePath.new('/etc')
    end

    cluster.cd('/etc')
    cluster.each do |host|
      expect(host.instance_variable_get(:@current_dir)).to eq('/etc')
    end

    StubNetwork.unstub_command!(:pwd)
    StubNetwork.unstub_command!(:realpath)
  end

  it 'changes current working directory for each host in a cluster' do
    cluster = described_class.new(host1, host2)

    StubNetwork.stub_command!(:pwd) do
      Kanrisuru::Core::Path::FilePath.new('/etc')
    end

    StubNetwork.stub_command!(:realpath) do
      Kanrisuru::Core::Path::FilePath.new('/etc')
    end

    cluster.chdir('/etc')
    cluster.each do |host|
      expect(host.instance_variable_get(:@current_dir)).to eq('/etc')
    end

    StubNetwork.unstub_command!(:pwd)
    StubNetwork.unstub_command!(:realpath)
  end

  it 'fails to remove a host from a cluster' do
    cluster = described_class.new(host1, host2)

    expect do
      cluster.delete(1)
    end.to raise_error(ArgumentError)
  end
end
