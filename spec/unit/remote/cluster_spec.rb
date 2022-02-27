# frozen_string_literal: true

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

  it 'responds to methods' do
    cluster = described_class.new(host1)
    expect(cluster).to respond_to(:hosts)
    expect(cluster).to respond_to(:[])
    expect(cluster).to respond_to(:<<)
    expect(cluster).to respond_to(:delete)
    expect(cluster).to respond_to(:execute)
    expect(cluster).to respond_to(:execute_shell)
    expect(cluster).to respond_to(:each)
    expect(cluster).to respond_to(:map)
    expect(cluster).to respond_to(:hostname)
    expect(cluster).to respond_to(:ping?)
    expect(cluster).to respond_to(:su)
    expect(cluster).to respond_to(:chdir)
    expect(cluster).to respond_to(:cd)
    expect(cluster).to respond_to(:disconnect)
    expect(cluster).to respond_to(:parallel)
    expect(cluster).to respond_to(:concurrency)
    expect(cluster).to respond_to(:parallel?)
    expect(cluster).to respond_to(:sequential?)
  end
end
