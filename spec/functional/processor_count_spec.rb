# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::ProcessorCount do
  it 'gets processor count' do
    expect(described_class.processor_count).to be > 0
  end 

  it 'gets physical processor count' do
    expect(described_class.physical_processor_count).to be > 0
  end

  it "is even factor of logical cpus" do
    expect(described_class.processor_count % described_class.physical_processor_count).to be == 0
  end
end
