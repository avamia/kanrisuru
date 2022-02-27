# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::ProcessorCount do
  it 'responds to methods' do
    expect(described_class).to respond_to(:processor_count)
    expect(described_class).to respond_to(:physical_processor_count)
  end
end
