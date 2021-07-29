# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::File do
  it 'responds to file fields' do
    expect(Kanrisuru::Core::File::FileCount.new).to respond_to(:lines, :words, :characters)
  end
end
