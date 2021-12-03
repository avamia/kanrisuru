# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Remote::Env do

  it 'responds to methods' do
    env = Kanrisuru::Remote::Env.new
    expect(env).to respond_to(:to_h)
    expect(env).to respond_to(:to_s)
    expect(env).to respond_to(:clear)
    expect(env).to respond_to(:count)
    expect(env).to respond_to(:count)
    expect(env).to respond_to(:delete)
    expect(env).to respond_to(:[])
    expect(env).to respond_to(:[]=)
  end

end
