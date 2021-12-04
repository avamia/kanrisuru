# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Yum do
  before(:all) do
    StubNetwork.stub!(:centos)
  end

  after(:all) do
    StubNetwork.unstub!
  end

  let(:host) do
    Kanrisuru::Remote::Host.new(
      host: 'centos-host',
      username: 'centos',
      keys: ['id_rsa']
    )
  end

  it 'prepares yum install command' do
    expect_command(host.yum('install', packages: 'nginx'),
                   'yum install -y nginx')

    expect_command(host.yum('install', packages: %w[nginx apache2]),
                   'yum install -y nginx apache2')
  end

  it 'prepares yum localinstall command' do
    expect_command(host.yum('localinstall', repos: 'foo.rpm'),
                   'yum localinstall -y foo.rpm')

    expect_command(host.yum('localinstall',
                            repos: ['foo.rpm', 'bar.rpm', 'baz.rpm'],
                            disable_repo: '*'),
                   'yum localinstall --disablerepo=* -y foo.rpm bar.rpm baz.rpm')
  end

  it 'prepares yum list command' do
    expect_command(host.yum('list'),
                   "yum list | tr '\\n' '#' | sed -e 's/# / /g' | tr '#' '\\n'")

    expect_command(host.yum('list', all: true, query: 'ruby*'),
                   "yum list all ruby* | tr '\\n' '#' | sed -e 's/# / /g' | tr '#' '\\n'")

    expect_command(host.yum('list',
                            available: true,
                            updates: true,
                            installed: true,
                            extras: true,
                            obsoletes: true,
                            disable_repo: '*'),
                   "yum list --disablerepo=* available updates installed extras obsoletes | tr '\\n' '#' | sed -e 's/# / /g' | tr '#' '\\n'")
  end

  it 'prepares yum search command' do
    expect_command(host.yum('search',
                            packages: 'redis'),
                   "yum search redis | tr '\\n' '#' | sed -e 's/# / /g' | tr '#' '\\n'")

    expect_command(host.yum('search',
                            packages: %w[package1 package2 package3],
                            all: true),
                   "yum search all package1 package2 package3 | tr '\\n' '#' | sed -e 's/# / /g' | tr '#' '\\n'")
  end

  it 'prepares yum info command' do
    expect_command(host.yum('info',
                            packages: 'redis'),
                   'yum info --quiet redis')

    expect_command(host.yum('info',
                            packages: %w[package1 package2 package3],
                            installed: true),
                   'yum info --quiet installed package1 package2 package3')
  end

  it 'prepares yum repolist command' do
    expect_command(host.yum('repolist'),
                   'yum repolist --verbose')

    expect_command(host.yum('repolist', repos: 'repo1'),
                   'yum repolist --verbose repo1')

    expect_command(host.yum('repolist', repos: %w[repo1 repo2 repo3]),
                   'yum repolist --verbose repo1 repo2 repo3')
  end

  it 'prepares yum clean command' do
    expect_command(host.yum('clean'), 'yum clean')
    expect_command(host.yum('clean', all: true), 'yum clean all')
    expect_command(host.yum('clean',
                            dbcache: true,
                            expire_cache: true,
                            metadata: true,
                            packages: true,
                            headers: true,
                            rpmdb: true),
                   'yum clean dbcache expire-cache metadata packages headers rpmdb')
  end

  it 'prepares yum remove command' do
    expect_command(host.yum('remove', packages: 'gcc'), 'yum remove -y gcc')
    expect_command(host.yum('remove', packages: %w[p1 p2 p3]),
                   'yum remove -y p1 p2 p3')

    expect do
      host.yum('remove', packages: 'yum')
    end.to raise_error(ArgumentError)
  end

  it 'prepares yum autoremove command' do
    expect_command(host.yum('autoremove'), 'yum autoremove -y')
  end

  it 'prepares yum erase command' do
    expect_command(host.yum('erase', packages: 'gcc'), 'yum erase -y gcc')
    expect_command(host.yum('erase', packages: %w[p1 p2 p3]),
                   'yum erase -y p1 p2 p3')

    expect do
      host.yum('erase', packages: 'yum')
    end.to raise_error(ArgumentError)
  end

  it 'prepares yum update command' do
    expect_command(host.yum('update'), 'yum update -y')
  end

  it 'prepares yum upgrade command' do
    expect_command(host.yum('upgrade'), 'yum upgrade -y')
  end
end
