# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Socket do
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

  it 'prepares ss command' do
    expect_command(host.ss, 'ss -a -m')

    expect_command(host.ss(
                     numeric: true,
                     tcp: true,
                     udp: true,
                     unix: true,
                     raw: true
                   ),
                   'ss -a -m -n -t -u -x -w')

    expect_command(host.ss(
                     family: 'inet'
                   ),
                   'ss -a -m -f inet')

    expect do
      host.ss(family: 'inet5')
    end.to raise_error(ArgumentError)

    expect_command(host.ss(
                     state: 'established'
                   ),
                   'ss -a -m state established')

    expect_command(host.ss(
                     state: 'connected'
                   ),
                   'ss -a -m state connected')

    expect do
      host.ss(state: 'test')
    end.to raise_error(ArgumentError)

    expect_command(host.ss(
                     expression: "'( dport = :ssh or sport = :ssh )'"
                   ),
                   "ss -a -m '( dport = :ssh or sport = :ssh )'")
  end
end
