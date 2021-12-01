# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Archive do
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
    expect(host).to respond_to(:tar)
  end

  it 'responds to archive fields' do
    expect(Kanrisuru::Core::Archive::FilePath.new).to respond_to(
      :path
    )
  end
end
