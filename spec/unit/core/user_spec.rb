# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::User do
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
    expect(host).to respond_to(:user?)
    expect(host).to respond_to(:get_uid)
    expect(host).to respond_to(:get_user)
    expect(host).to respond_to(:create_user)
    expect(host).to respond_to(:update_user)
    expect(host).to respond_to(:delete_user)
  end

  it 'responds to user fields' do
    expect(Kanrisuru::Core::User::User.new).to respond_to(:uid, :name, :home, :shell, :groups)
    expect(Kanrisuru::Core::User::UserGroup.new).to respond_to(:gid, :name)
    expect(Kanrisuru::Core::User::FilePath.new).to respond_to(:path)
  end
end
