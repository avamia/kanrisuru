# frozen_string_literal: true

require 'spec_helper'

TestHosts.each_os(only: %w[sles]) do |os_name, host_json, spec_dir|
  RSpec.describe Kanrisuru::Core::Group do
    include_examples "group", os_name, host_json, spec_dir
  end
end
