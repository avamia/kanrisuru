# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Apt do
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

  it 'prepares apt list command' do
    expect_command(host.apt('list'), 'apt list')
    expect_command(host.apt('list',
                            installed: true,
                            upgradeable: true,
                            all_versions: true), 'apt list --installed --upgradeable --all-versions')

    expect_command(host.apt('list', package_name: 'nginx'), 'apt list -a nginx')
  end

  it 'prepares apt update command' do
    expect_command(host.apt('update'), 'apt-get update -y')
  end

  it 'prepares apt upgrade command' do
    expect_command(host.apt('upgrade'), 'apt-get upgrade -y')
  end

  it 'prepares apt full-upgrade command' do
    expect_command(host.apt('full-upgrade'), 'apt full-upgrade -y')
  end

  it 'prepares apt install command' do
    expect_command(host.apt('install',
                            packages: 'nginx'),
                   'apt-get install -y nginx')

    expect_command(host.apt('install',
                            packages: 'monit',
                            no_upgrade: true,
                            reinstall: true),
                   'apt-get install -y --no-upgrade --reinstall monit')

    expect_command(host.apt('install',
                            packages: %w[build-essential manpages-dev],
                            only_upgrade: true),
                   'apt-get install -y --only-upgrade build-essential manpages-dev')
  end

  it 'prepares apt remove command' do
    expect_command(host.apt('remove', packages: ['python']), 'apt-get remove -y python')
  end

  it 'prepares apt purge command' do
    expect_command(host.apt('purge', packages: ['python']), 'apt-get purge -y python')
  end

  it 'prepares apt autoremove command' do
    expect_command(host.apt('autoremove'), 'apt-get autoremove -y')
  end

  it 'prepares apt search command' do
    expect_command(host.apt('search', query: 'ruby'), 'apt search ruby')
  end

  it 'prepares apt show command' do
    expect_command(host.apt('show', packages: 'ruby'), 'apt show -a ruby')
  end

  it 'prepares apt clean command' do
    expect_command(host.apt('clean'), 'apt-get clean')
  end

  it 'prepares apt autoclean command' do
    expect_command(host.apt('autoclean'), 'apt-get autoclean')
  end
end
