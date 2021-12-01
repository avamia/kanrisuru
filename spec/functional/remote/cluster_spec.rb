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
    cluster = Kanrisuru::Remote::Cluster.new(host1)
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
  end

  it 'removes a host from a cluster' do
    cluster = Kanrisuru::Remote::Cluster.new(host1, host2)
    expect(cluster.count).to eq(2)

    cluster.delete(host2)
    expect(cluster.count).to eq(1)
    expect(cluster.hosts).not_to include(host2)

    cluster.delete(host1.host)
    expect(cluster.count).to eq(0)
    expect(cluster.hosts).not_to include(host1)
  end
end
