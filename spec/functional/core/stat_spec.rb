# frozen_string_literal: true

require 'spec_helper'

StubNetwork.stub!

RSpec.describe Kanrisuru::Core::Stat do
  let(:host) do
    Kanrisuru::Remote::Host.new(
      host: 'localhost',
      username: 'ubuntu', 
      keys: ['id_rsa']
    )
  end

  it 'prepares stat command' do
    result = host.stat('~/file1.txt')
    expect(result.command.raw_command).to eq(
      'stat -c %A,%b,%D,%F,%g,%G,%h,%i,%n,%s,%u,%U,%x,%y,%z ~/file1.txt'
    )

    result = host.stat('~/file2.txt', follow: true)
    expect(result.command.raw_command).to eq(
      'stat -L -c %A,%b,%D,%F,%g,%G,%h,%i,%n,%s,%u,%U,%x,%y,%z ~/file1.txt'
    )
  end

end
