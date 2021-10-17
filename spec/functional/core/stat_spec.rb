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
    expect_command(host.stat('~/file1.txt'),
                   'stat -c %A,%b,%D,%F,%g,%G,%h,%i,%n,%s,%u,%U,%x,%y,%z ~/file1.txt')

    expect_command(host.stat('~/file2.txt', follow: true),
                   'stat -L -c %A,%b,%D,%F,%g,%G,%h,%i,%n,%s,%u,%U,%x,%y,%z ~/file2.txt')
  end
end
