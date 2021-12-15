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

  it 'prepares create_user command' do
    expect_command(host.create_user('bob'), 'useradd bob -s /bin/false')
    expect_command(host.create_user('bob', uid: 5555), 'useradd bob -u 5555 -s /bin/false')
    expect_command(host.create_user('bob', uid: 5555, non_unique: true), 'useradd bob -u 5555 -o -s /bin/false')
    expect_command(host.create_user('bob', system: true), 'useradd bob -r -s /bin/false')
    expect_command(host.create_user('bob', shell: '/bin/bash'), 'useradd bob -s /bin/bash')
    expect_command(host.create_user('bob', home: '/home/bob1'), 'useradd bob -s /bin/false -d /home/bob1')
    expect_command(host.create_user('bob', home: '/home/bob1', createhome: true),
                   'useradd bob -s /bin/false -d /home/bob1 -m')
    expect_command(host.create_user('bob', home: '/home/bob1', createhome: true, skeleton: '/home/bob1skele'),
                   'useradd bob -s /bin/false -d /home/bob1 -m -k /home/bob1skele')
    expect_command(host.create_user('bob', createhome: false), 'useradd bob -s /bin/false -M')
    expect_command(host.create_user('bob', password: '12345678'), 'useradd bob -s /bin/false -p 12345678')
    expect_command(host.create_user('bob', expires: '2021-12-31'), 'useradd bob -s /bin/false -e 2021-12-31')

    expect_command(host.create_user('bob', groups: %w[www-data sudo admin]),
                   'useradd bob -s /bin/false -G www-data,sudo,admin')

    StubNetwork.stub_command!(:group?, { return_value: true })
    expect_command(host.create_user('bob', group: 'www-data'), 'useradd bob -s /bin/false -g www-data')
    expect_command(host.create_user('bob'), 'useradd bob -s /bin/false -N')
    StubNetwork.unstub_command!(:group?)
  end

  it 'prepares delete_user command' do
    StubNetwork.stub_command!(:get_uid) { 1000 }
    expect_command(host.delete_user('ubuntu'), 'userdel ubuntu')
    expect_command(host.delete_user('ubuntu', force: true), 'userdel ubuntu -f')
    StubNetwork.unstub_command!(:get_uid)

    StubNetwork.stub_command!(:get_uid, { status: 1 })
    expect(host.delete_user('ubuntu')).to be_falsey
    StubNetwork.unstub_command!(:get_uid)
  end

  it 'prepares get_uid command' do
    expect_command(host.get_uid('ubuntu'), 'id -u ubuntu')
  end

  it 'prepares get_user command' do
    expect_command(host.get_user('ubuntu'), 'id ubuntu')
  end

  it 'prepares user? command' do
    StubNetwork.stub_command!(:get_uid) { 1000 }
    expect(host).to be_user('ubuntu')
    StubNetwork.unstub_command!(:get_uid)

    StubNetwork.stub_command!(:get_uid, { status: 1 })
    expect(host).not_to be_group('ubuntu')
    StubNetwork.unstub_command!(:get_uid)
  end

  it 'prepares update_user command' do
    expect_command(host.update_user('bob', home: '/home/bob'), 'usermod bob -d /home/bob')
    expect_command(host.update_user('bob', home: '/home/bob', move_home: true), 'usermod bob -d /home/bob -m')
    expect_command(host.update_user('bob', home: '/home/bob', move_home: true), 'usermod bob -d /home/bob -m')
    expect_command(host.update_user('bob', shell: '/bin/zsh'), 'usermod bob -s /bin/zsh')
    expect_command(host.update_user('bob', uid: 6431), 'usermod bob -u 6431')
    expect_command(host.update_user('bob', uid: 1000, non_unique: true), 'usermod bob -u 1000 -o')

    StubNetwork.stub_command!(:group?, { return_value: true })
    expect_command(host.update_user('bob', group: 'backup'), 'usermod bob -g backup')
    StubNetwork.unstub_command!(:group?)

    expect_command(host.update_user('bob', groups: 'backup'), 'usermod bob -G backup')
    expect_command(host.update_user('bob', groups: %w[backup mail]), 'usermod bob -G backup,mail')
    expect_command(host.update_user('bob', groups: %w[backup mail], append: true), 'usermod bob -G backup,mail -a')

    expect_command(host.update_user('bob', locked: true), 'usermod bob -L -e 1')
    expect_command(host.update_user('bob', locked: false), 'usermod bob -U -e 99999')
    expect_command(host.update_user('bob', locked: false, password: '123456'), 'usermod bob -U -e 99999')
    expect_command(host.update_user('bob', password: '123456'), 'usermod bob -p 123456')
    expect_command(host.update_user('bob', expires: '2022-01-01'), 'usermod bob -e 2022-01-01')
  end
end
