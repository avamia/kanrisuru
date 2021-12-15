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

  it 'prepares create_group command' do
    expect_command(host.create_group('admin'), 'groupadd admin')
    expect_command(host.create_group('admin', { gid: 9000 }), 'groupadd admin -g 9000')
  end

  it 'prepares delete_group command' do
    StubNetwork.stub_command!(:group?, { return_value: true })
    expect_command(host.delete_group('admin'), 'groupdel admin')
    StubNetwork.unstub_command!(:group?)
    StubNetwork.stub_command!(:group?, { return_value: false })
    expect(host.delete_group('admin')).to be_falsey
    StubNetwork.unstub_command!(:group?)
  end

  it 'prepares get_gid command' do
    expect_command(host.get_gid('ubuntu'), 'getent group ubuntu')
  end

  it 'prepares get_group command' do
    expect_command(host.get_group('ubuntu'), 'getent group ubuntu | cut -d: -f4')
  end

  it 'prepares group? command' do
    StubNetwork.stub_command!(:get_gid) do
      1000
    end
    expect(host).to be_group('ubuntu')
    StubNetwork.unstub_command!(:get_gid)

    StubNetwork.stub_command!(:get_gid, { status: 1 })
    expect(host).not_to be_group('ubuntu')
    StubNetwork.unstub_command!(:get_gid)
  end

  it 'prepares update_group command' do
    expect_command(host.update_group('www-data', { gid: 34, new_name: 'web' }), 'groupmod www-data -g 34 -n web')
    expect(host.update_group('www-data')).to be_nil
    expect(host.update_group('www-data', { gid: 0, new_name: '' })).to be_nil
    expect(host.update_group('www-data', { gid: '', new_name: 'test' })).to be_nil
  end
end
