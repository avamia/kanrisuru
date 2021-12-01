# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Transfer do
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
    expect(host).to respond_to(:download)
    expect(host).to respond_to(:upload)
    expect(host).to respond_to(:wget)
  end

  it 'responds to transfer fields' do
    expect(Kanrisuru::Core::Transfer::WGET_FILENAME_MODES).to eq(
      %w[unix windows nocontrol ascii lowercase uppercase]
    )

    expect(Kanrisuru::Core::Transfer::WGET_SSL_PROTO).to eq(
      %w[auto SSLv2 SSLv3 TLSv1]
    )
  end
end
