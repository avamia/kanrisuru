# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Group do
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
    expect(host).to respond_to(:group?)
    expect(host).to respond_to(:get_gid)
    expect(host).to respond_to(:create_group)
    expect(host).to respond_to(:update_group)
    expect(host).to respond_to(:delete_group)
  end

  it 'responds to group fields' do
    expect(Kanrisuru::Core::Group::Group.new).to respond_to(:gid, :name, :users)
    expect(Kanrisuru::Core::Group::GroupUser.new).to respond_to(:uid, :name)
  end
end
