# frozen_string_literal: true

RSpec.describe Kanrisuru::Remote::Host do
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

  it 'responds to methods' do
    expect(host).to respond_to(:remote_user)
    expect(host).to respond_to(:hostname)
    expect(host).to respond_to(:os)
    expect(host).to respond_to(:env)
    expect(host).to respond_to(:template)
    expect(host).to respond_to(:fstab)
    expect(host).to respond_to(:chdir)
    expect(host).to respond_to(:cd)
    expect(host).to respond_to(:cpu)
    expect(host).to respond_to(:memory)
    expect(host).to respond_to(:su)
    expect(host).to respond_to(:file)
    expect(host).to respond_to(:ssh)
    expect(host).to respond_to(:proxy)
    expect(host).to respond_to(:ping?)
    expect(host).to respond_to(:execute)
    expect(host).to respond_to(:execute_shell)
    expect(host).to respond_to(:disconnect)
  end
end
