# frozen_string_literal: true

require 'spec_helper'

TestHosts.each_os(only: %w[opensuse]) do |os_name, host_json, spec_dir|
  RSpec.describe Kanrisuru::Core::Disk do
    include_examples "disk", os_name, host_json, spec_dir
  end
end
