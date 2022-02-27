# frozen_string_literal: true

require 'benchmark'
require 'spec_helper'

RSpec.describe Kanrisuru::Remote::Cluster do
  let(:host1) do
    Kanrisuru::Remote::Host.new(
      host: TestHosts.host('ubuntu')['hostname'],
      username: TestHosts.host('ubuntu')['username'],
      keys: [TestHosts.host('ubuntu')['ssh_key']]
    )
  end

  let(:host2) do
    Kanrisuru::Remote::Host.new(
      host: TestHosts.host('debian')['hostname'],
      username: TestHosts.host('debian')['username'],
      keys: [TestHosts.host('debian')['ssh_key']]
    )
  end

  let(:host3) do
    Kanrisuru::Remote::Host.new(
      host: TestHosts.host('centos')['hostname'],
      username: TestHosts.host('centos')['username'],
      keys: [TestHosts.host('centos')['ssh_key']]
    )
  end

  let(:host4) do
    Kanrisuru::Remote::Host.new(
      host: TestHosts.host('opensuse')['hostname'],
      username: TestHosts.host('opensuse')['username'],
      keys: [TestHosts.host('opensuse')['ssh_key']]
    )
  end

  it 'gets hostname for cluster' do
    cluster = described_class.new(host1, host2, host3, host4)
    expect(cluster.hostname).to match([
                                        { host: 'ubuntu-host', result: 'ubuntu-host' },
                                        { host: 'debian-host', result: 'debian-host' },
                                        { host: 'centos-host', result: 'centos-host' },
                                        { host: 'opensuse-host', result: 'opensuse-host' },
                                      ])

    cluster.disconnect
  end

  it 'can ping host cluster' do
    cluster = described_class.new(host1, host2, host3, host4)
    expect(cluster.ping?).to match([
                                    { host: 'ubuntu-host', result: true },
                                    { host: 'debian-host', result: true },
                                    { host: 'centos-host', result: true },
                                    { host: 'opensuse-host', result: true },
                                   ])

    cluster.disconnect
  end

  it 'should use specific number of threads as number of hosts' do
    cluster = described_class.new(host1, host2, host3, host4)
    cluster.parallel = true

    ## Called x2 b/c two methods invoke the parallel runner 
    expect(Thread).to receive(:new).exactly(cluster.count * 2).times.and_call_original

    cluster.hostname
    cluster.disconnect
  end

  it 'should respect concurrency setting' do
    concurrency = 2

    cluster = described_class.new(host1, host2, host3, host4)
    cluster.parallel = true
    cluster.concurrency = concurrency

    ## Called x2 b/c two methods invoke the parallel runner 
    expect(Thread).to receive(:new).exactly(concurrency * 2).times.and_call_original

    cluster.hostname
    cluster.disconnect
  end

  it 'saves time running cluster in parallel mode' do
    cluster = described_class.new(host1, host2, host3, host4)
    time1 = Benchmark.measure {
      cluster.each do |host|
        expect(host.pwd).to be_success
      end
    }

    cluster.parallel = true
    time2 = Benchmark.measure {
      cluster.each do |host|
        expect(host.pwd).to be_success
      end
    }

    expect(time1.total).to be > time2.total
    cluster.disconnect
  end

  it 'disconnects all hosts' do
    cluster = described_class.new(host1, host2, host3, host4)
    cluster.disconnect

    cluster.each do |host|
      expect(host.ssh).to be_closed
    end
  end
end
