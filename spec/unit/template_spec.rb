# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Template do
  it 'reads template file' do
    path = '/home/ubuntu/kanrisuru/templates/test.conf.erb'
    template = described_class.new(path, array: %w[hello world])
    template.trim_mode = '-'

    puts template.render
  end
end
