# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::Archive do
  it 'responds to archive fields' do
    expect(Kanrisuru::Core::Archive::FilePath.new).to respond_to(
      :path
    )
  end
end
