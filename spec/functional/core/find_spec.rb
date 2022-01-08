# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Find do
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

  it 'prepares find command' do
    expect_command(host.find, 'find')

    expect_command(host.find(follow: 'never'), 'find -P')
    expect_command(host.find(follow: 'always'), 'find -L')
    expect_command(host.find(follow: 'command'), 'find -H')

    expect_command(host.find(paths: '/etc'), 'find /etc')
    expect_command(host.find(paths: ['/etc', '/var', '/home']), 'find /etc /var /home')

    expect do
      host.find(paths: 1)
    end.to raise_error(ArgumentError)

    expect_command(host.find(paths: '/',
                             executable: true,
                             empty: true,
                             readable: true,
                             writeable: true,
                             nogroup: true,
                             nouser: true,
                             mount: true),
                   'find / -executable -empty -readable -nogroup -nouser -mount')

    expect_command(host.find(paths: '/',
                             path: '/lib',
                             name: '*.so',
                             gid: 0,
                             uid: 0,
                             user: 'root',
                             group: 'root',
                             links: 2,
                             mindepth: 0,
                             maxdepth: 100),
                   'find / -path /lib -name *.so -gid 0 -uid 0 -user root -group root -links 2 -maxdepth 100 -mindepth 0')

    expect_command(host.find(paths: '/var/log',
                             atime: '+1',
                             ctime: '+2',
                             mtime: '+3',
                             amin: '100',
                             cmin: '200',
                             mmin: '300'),
                   'find /var/log -atime +1 -ctime +2 -mtime +3 -amin 100 -cmin 200 -mmin 300')

    expect_command(host.find(
                     paths: '/dev',
                     iname: 'tty*'
                   ),
                   'find /dev -iname tty*')

    expect_command(host.find(
                     paths: '/dev',
                     regex: '/dev/tty[0-9]*'
                   ),
                   "find /dev -regex '/dev/tty[0-9]*'")

    expect_command(host.find(
                     paths: '/dev',
                     iregex: '/dev/tty[0-9]*'
                   ),
                   "find /dev -iregex '/dev/tty[0-9]*'")

    expect_command(host.find(
                     paths: '/dev',
                     regex_type: 'posix-egrep',
                     regex: '/dev/tty[0-9]*'
                   ),
                   "find /dev -regextype posix-egrep -regex '/dev/tty[0-9]*'")

    expect_command(host.find(
                     paths: '/var/log',
                     size: 100
                   ),
                   'find /var/log -size 100')

    expect_command(host.find(
                     paths: '/var/log',
                     size: '100'
                   ),
                   'find /var/log -size 100')

    expect do
      host.find(size: '100n')
    end.to raise_error(ArgumentError)

    expect_command(host.find(
                     paths: '/var/log',
                     size: '-100k'
                   ),
                   'find /var/log -size -100k')

    expect_command(host.find(
                     paths: '/var/log',
                     size: '+10M'
                   ),
                   'find /var/log -size +10M')

    expect_command(host.find(
                     paths: '/dev',
                     type: 'directory'
                   ),
                   'find /dev -type d')

    expect_command(host.find(
                     paths: '/dev',
                     type: 'file'
                   ),
                   'find /dev -type f')

    expect_command(host.find(
                     paths: '/dev',
                     type: 'symlinks'
                   ),
                   'find /dev -type l')

    expect_command(host.find(
                     paths: '/dev',
                     type: 'block'
                   ),
                   'find /dev -type b')

    expect_command(host.find(
                     paths: '/dev',
                     type: 'character'
                   ),
                   'find /dev -type c')

    expect_command(host.find(
                     paths: '/dev',
                     type: 'pipe'
                   ),
                   'find /dev -type p')

    expect_command(host.find(
                     paths: '/dev',
                     type: 'socket'
                   ),
                   'find /dev -type s')
  end
end
