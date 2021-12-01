# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Stat do
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
    expect(host).to respond_to(:dir?)
    expect(host).to respond_to(:file?)
    expect(host).to respond_to(:block_device?)
    expect(host).to respond_to(:char_device?)
    expect(host).to respond_to(:symlink?)
    expect(host).to respond_to(:file_type?)
    expect(host).to respond_to(:inode?)
    expect(host).to respond_to(:stat)
  end

  it 'responds to stat fields' do
    expect(Kanrisuru::Core::Stat::FileStat.new).to respond_to(
      :mode, :blocks, :device, :file_type,
      :gid, :group, :links, :inode,
      :path, :fsize, :uid, :user,
      :last_access, :last_modified, :last_changed
    )
  end
end
