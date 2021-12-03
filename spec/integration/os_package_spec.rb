# frozen_string_literal: true

require 'spec_helper'

module Kanrisuru
  module TestInclude
    extend Kanrisuru::OsPackage::Define

    os_define :ubuntu, :tester

    def tester
      'hello ubuntu'
    end
  end

  module TestNamespace
    extend Kanrisuru::OsPackage::Define

    os_define :linux, :tester
    os_define :centos, :test_not_correct

    def tester
      'hello namespace'
    end

    def test_not_correct; end
  end

  module TestNamespaceAdditions
    extend Kanrisuru::OsPackage::Define

    os_define :linux, :add
    os_define :linux, :minus

    def add(a, b)
      a + b
    end

    def minus(a, b)
      a - b
    end
  end

  module TestAliasNames
    extend Kanrisuru::OsPackage::Define

    os_define :fedora, :output_fedora, alias: :output
    os_define :debian, :output_debian, alias: :output
    os_define :sles,   :output_sles, alias: :output

    def output_debian
      'debian'
    end

    def output_fedora
      'fedora'
    end

    def output_sles
      'sles'
    end
  end

  module TestAliasNamesNamespace
    extend Kanrisuru::OsPackage::Define

    os_define :fedora, :output_fedora, alias: :output
    os_define :debian, :output_debian, alias: :output
    os_define :sles,   :output_sles, alias: :output

    def output_debian
      'debian'
    end

    def output_fedora
      'fedora'
    end

    def output_sles
      'sles'
    end
  end
end

module Kanrisuru
  module Remote
    class Host
      os_include Kanrisuru::TestInclude

      os_include Kanrisuru::TestAliasNames
      os_include Kanrisuru::TestAliasNamesNamespace, namespace: :alias

      os_include Kanrisuru::TestNamespaceAdditions, namespace: :asdf
      os_include Kanrisuru::TestNamespace, namespace: :asdf
    end

    class Cluster
      os_collection Kanrisuru::TestInclude

      os_collection Kanrisuru::TestAliasNames
      os_collection Kanrisuru::TestAliasNamesNamespace, namespace: :alias

      os_collection Kanrisuru::TestNamespaceAdditions, namespace: :asdf
      os_collection Kanrisuru::TestNamespace, namespace: :asdf
    end
  end
end

RSpec.describe Kanrisuru::OsPackage do
  it 'includes with os_include' do
    host = Kanrisuru::Remote::Host.new(host: '127.0.0.1', username: 'ubuntu', keys: ['~/.ssh/id_rsa'])
    host2 = Kanrisuru::Remote::Host.new(host: 'localhost', username: 'ubuntu', keys: ['~/.ssh/id_rsa'])

    cluster = Kanrisuru::Remote::Cluster.new(host, host2)

    expect(host).to respond_to(:tester)
    expect(host.tester).to eq('hello ubuntu')
    expect(cluster.tester).to be_instance_of(Array)

    host.disconnect
    cluster.disconnect
  end

  it 'includes a namespaced os_include' do
    host = Kanrisuru::Remote::Host.new(host: '127.0.0.1', username: 'ubuntu', keys: ['~/.ssh/id_rsa'])
    host2 = Kanrisuru::Remote::Host.new(host: 'localhost', username: 'ubuntu', keys: ['~/.ssh/id_rsa'])

    cluster = Kanrisuru::Remote::Cluster.new(host, host2)

    expect(host).to respond_to(:asdf)
    expect(host.asdf).to respond_to(:tester)
    expect(host.asdf).to respond_to(:add)
    expect(host.asdf).to respond_to(:minus)

    expect(host.asdf.tester).to eq 'hello namespace'
    expect(host.asdf.add(1, 2)).to eq(3)
    expect(host.asdf.minus(3, 2)).to eq(1)

    expect(host.tester).to eq('hello ubuntu')

    expect { host.asdf.test_not_correct }.to raise_error(NoMethodError)
    expect(cluster.asdf.tester).to be_instance_of(Array)

    host.disconnect
    host2.disconnect
    cluster.disconnect
  end

  it 'includes the correct alias named method' do
    host1 = Kanrisuru::Remote::Host.new(host: 'ubuntu-host', username: 'ubuntu', keys: ['~/.ssh/id_rsa'])
    host2 = Kanrisuru::Remote::Host.new(host: 'centos-host', username: 'centos', keys: ['~/.ssh/id_rsa'])
    host3 = Kanrisuru::Remote::Host.new(host: 'opensuse-host', username: 'opensuse', keys: ['~/.ssh/id_rsa'])

    cluster = Kanrisuru::Remote::Cluster.new(host1, host2, host3)

    expect(host1).to respond_to(:output)
    expect(host2).to respond_to(:output)
    expect(host3).to respond_to(:output)
    expect(host1.output).to eq('debian')
    expect(host2.output).to eq('fedora')
    expect(host3.output).to eq('sles')

    expect(cluster).to respond_to(:output)
    expect(cluster.output).to eq([
                                   { host: 'ubuntu-host', result: 'debian' },
                                   { host: 'centos-host', result: 'fedora' },
                                   { host: 'opensuse-host', result: 'sles' }
                                 ])

    expect(host1).to respond_to(:alias)
    expect(host2).to respond_to(:alias)
    expect(host3).to respond_to(:alias)
    expect(host1.alias).to respond_to(:output)
    expect(host2.alias).to respond_to(:output)
    expect(host3.alias).to respond_to(:output)
    expect(host1.alias.output).to eq('debian')
    expect(host2.alias.output).to eq('fedora')
    expect(host3.alias.output).to eq('sles')

    expect(cluster).to respond_to(:alias)
    expect(cluster.alias).to respond_to(:output)
    expect(cluster.alias.output).to eq([
                                         { host: 'ubuntu-host', result: 'debian' },
                                         { host: 'centos-host', result: 'fedora' },
                                         { host: 'opensuse-host', result: 'sles' }
                                       ])

    host1.disconnect
    host2.disconnect
    host3.disconnect
    cluster.disconnect
  end
end
