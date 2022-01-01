# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru do
  it 'has a version number' do
    expect(Kanrisuru::VERSION).not_to be nil
  end

  it 'has logger class' do
    expect(Kanrisuru::Logger).not_to be nil
  end
end
