# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::File do
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
    expect(host).to respond_to(:touch)
    expect(host).to respond_to(:cp)
    expect(host).to respond_to(:copy)
    expect(host).to respond_to(:mkdir)
    expect(host).to respond_to(:mv)
    expect(host).to respond_to(:move)
    expect(host).to respond_to(:link)
    expect(host).to respond_to(:symlink)
    expect(host).to respond_to(:ln)
    expect(host).to respond_to(:ln_s)
    expect(host).to respond_to(:chmod)
    expect(host).to respond_to(:chown)
    expect(host).to respond_to(:unlink)
    expect(host).to respond_to(:rm)
    expect(host).to respond_to(:rmdir)
    expect(host).to respond_to(:wc)
  end

  it 'responds to file fields' do
    expect(Kanrisuru::Core::File::FileCount.new).to respond_to(:lines, :words, :characters)
  end
end
