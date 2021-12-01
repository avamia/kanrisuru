# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Path do
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
    expect(host).to respond_to(:ls)
    expect(host).to respond_to(:pwd)
    expect(host).to respond_to(:realpath)
    expect(host).to respond_to(:readlink)
    expect(host).to respond_to(:whoami)
    expect(host).to respond_to(:which)
  end

  it 'responds to path fields' do
    expect(Kanrisuru::Core::Path::FilePath.new).to respond_to(:path)
    expect(Kanrisuru::Core::Path::FileInfoId.new).to respond_to(
      :inode, :mode, :hard_links, :uid, :gid, :fsize, :date, :path, :type
    )
    expect(Kanrisuru::Core::Path::FileInfo.new).to respond_to(
      :inode, :mode, :hard_links, :owner, :group, :fsize, :date, :path, :type
    )
    expect(Kanrisuru::Core::Path::UserName.new).to respond_to(:user)
  end
end
