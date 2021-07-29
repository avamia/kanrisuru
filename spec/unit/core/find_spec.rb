# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Find do
  it 'responds to find fields' do
    expect(Kanrisuru::Core::Find::FilePath.new).to respond_to(:path)
  end
end
