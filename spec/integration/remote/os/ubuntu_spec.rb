# frozen_string_literal: true

require 'spec_helper'

TestHosts.each_os(only: %w[ubuntu]) do |os_name, host_json, spec_dir|
  RSpec.describe Kanrisuru::Remote::Os do
    include_examples 'os', os_name, host_json, spec_dir
  end
end
