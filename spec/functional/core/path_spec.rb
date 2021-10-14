# frozen_string_literal: true

require 'spec_helper'

StubNetwork.stub!

RSpec.describe Kanrisuru::Core::Path do
  let(:host) do
    Kanrisuru::Remote::Host.new(
      host: 'localhost',
      username: 'ubuntu', 
      keys: ['id_rsa']
    )
  end

  it 'prepares ls command' do
    expect_command(host.ls(path: '/etc'), 'ls -i -l /etc')
    expect_command(host.ls(path: '/var/log', all: true, id: true), 'ls -i -l -a -n /var/log')
  end

  it 'prepares pwd command' do
    expect_command(host.pwd, 'pwd')
  end

  it 'prepares whoami command' do
    expect_command(host.whoami, 'whoami')
  end

  it 'prepares which command' do
    expect_command(host.which('which'), 'which which')
    expect_command(host.which('pwd', all: true), 'which -a pwd')
  end

  it 'prepares realpath command' do
    expect_command(host.realpath('/etc/os-release'), 'realpath /etc/os-release')
    expect_command(host.realpath('/etc/os-release', strip: true), 'realpath /etc/os-release -s')
  end

  it 'prepares readlink command' do
    expect_command(host.readlink('/etc/os-release'), 'readlink /etc/os-release')
    expect_command(host.readlink('/etc/os-release', canonicalize: true), 'readlink -f /etc/os-release')
    expect_command(host.readlink('/etc/os-release', canonicalize_existing: true), 'readlink -e /etc/os-release')
    expect_command(host.readlink('/etc/os-release', canonicalize_missing: true), 'readlink -m /etc/os-release')
  end

end
