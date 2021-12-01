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

  it 'responds to methods' do
    expect(host).to respond_to(:ss)
  end

  it 'responds to socket fields' do
    expect(Kanrisuru::Core::Socket::Statistics.new).to respond_to(
      :netid, :state, :receive_queue, :send_queue,
      :local_address, :local_port, :peer_address, :peer_port,
      :memory
    )
    expect(Kanrisuru::Core::Socket::StatisticsMemory.new).to respond_to(
      :rmem_alloc, :rcv_buf, :wmem_alloc, :snd_buf,
      :fwd_alloc, :wmem_queued, :ropt_mem, :back_log, :sock_drop
    )
    expect(Kanrisuru::Core::Socket::TCP_STATES).to eq(
      %w[
        established syn-sent syn-recv
        fin-wait-1 fin-wait-2 time-wait
        closed close-wait last-ack listening closing
      ]
    )
    expect(Kanrisuru::Core::Socket::NETWORK_FAMILIES).to eq(
      %w[
        unix inet inet6 link netlink
      ]
    )
    expect(Kanrisuru::Core::Socket::OTHER_STATES).to eq(
      %w[
        all connected synchronized bucket syn-recv
        big
      ]
    )
    expect(Kanrisuru::Core::Socket::TCP_STATE_ABBR).to eq(
      {
        'ESTAB' => 'established', 'LISTEN' => 'listening', 'UNCONN' => 'unconnected',
        'SYN-SENT' => 'syn-sent', 'SYN-RECV' => 'syn-recv', 'FIN-WAIT-1' => 'fin-wait-1',
        'FIN-WAIT-2' => 'fin-wait-2', 'TIME-WAIT' => 'time-wait', 'CLOSE-WAIT' => 'close-wait',
        'LAST-ACK' => 'last-ack', 'CLOSING' => 'closing'
      }
    )
  end
end
