# frozen_string_literal: true

require 'spec_helper'

TestHosts.each_os(only: %w[fedora]) do |os_name, host_json, spec_dir|
  RSpec.describe Kanrisuru::Core::IP do
    include_examples 'ip', os_name, host_json, spec_dir
  end
end
