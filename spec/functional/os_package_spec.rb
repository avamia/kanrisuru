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

    os_define :unix_like, :tester
    os_define :centos, :test_not_correct

    def tester
      'hello namespace'
    end

    def test_not_correct; end
  end
end

module Kanrisuru
  module Remote
    class Host
      os_include Kanrisuru::TestInclude
      os_include Kanrisuru::TestNamespace, namespace: :asdf
    end

    class Cluster
      os_collection Kanrisuru::TestInclude
      os_collection Kanrisuru::TestNamespace, namespace: :asdf
    end
  end
end

RSpec.describe Kanrisuru::OsPackage do
  it 'includes with os_include' do
    host = Kanrisuru::Remote::Host.new(host: '127.0.0.1', username: 'ubuntu', keys: ['~/.ssh/id_rsa'])
    host2 = Kanrisuru::Remote::Host.new(host: 'localhost', username: 'ubuntu', keys: ['~/.ssh/id_rsa'])

    cluster = Kanrisuru::Remote::Cluster.new([host, host2])

    expect(host).to respond_to(:tester)
    expect(host.tester).to eq('hello ubuntu')
    expect(cluster.tester).to be_instance_of(Array)

    host.disconnect
    cluster.disconnect
  end

  it 'includes a namespaced os_include' do
    host = Kanrisuru::Remote::Host.new(host: '127.0.0.1', username: 'ubuntu', keys: ['~/.ssh/id_rsa'])
    host2 = Kanrisuru::Remote::Host.new(host: 'localhost', username: 'ubuntu', keys: ['~/.ssh/id_rsa'])

    cluster = Kanrisuru::Remote::Cluster.new([host, host2])

    expect(host).to respond_to(:asdf)
    expect(host.asdf).to respond_to(:tester)
    expect(host.asdf.tester).to eq 'hello namespace'
    expect(host.tester).to eq('hello ubuntu')
    expect { host.asdf.test_not_correct }.to raise_error(NoMethodError)
    expect(cluster.asdf.tester).to be_instance_of(Array)

    host.disconnect
    cluster.disconnect
  end
end
