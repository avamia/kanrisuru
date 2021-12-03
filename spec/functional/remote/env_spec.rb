# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Remote::Env do

  let (:env) { Kanrisuru::Remote::Env.new }

  it 'adds a environment variable' do
    env['VAR1'] = 'hello'
    expect(env.count).to eq(1)
    expect(env.to_h).to eq({'VAR1' => 'hello'})
    expect(env.to_s).to eq('export VAR1=hello;')
    expect(env['VAR1']).to eq('hello')
  end

  it 'adds multiple environment variables' do
    env['var1'] = 'hello'
    env['var2'] = 'world'

    expect(env.count).to eq(2)
    expect(env.to_h).to eq({'VAR1' => 'hello', 'VAR2' => 'world'})
    expect(env.to_s).to eq('export VAR1=hello; export VAR2=world;')
    expect(env['VAR1']).to eq('hello')
    expect(env['VAR2']).to eq('world')
  end

  it 'deletes a variable' do
    env[:var1] = 'foo'
    expect(env.count).to eq(1)
    expect(env[:var1]).to eq('foo')
    env.delete(:var1)
    expect(env.count).to eq(0)
    expect(env.to_s).to eq('')
  end

  it 'clears the environment' do
    env['VERSION'] = 1
    env['SHELL'] = '/bin/zsh'
    env['USER'] = 'ubuntu'
    env['HOSTNAME'] = 'ubuntu'
    expect(env.to_s).to eq('export VERSION=1; export SHELL=/bin/zsh; export USER=ubuntu; export HOSTNAME=ubuntu;')

    expect(env.count).to eq(4)
    env.clear

    expect(env.count).to eq(0)
  end

end
