# frozen_string_literal: true

require 'spec_helper'

TestHosts.each_os(only: %w[fedora]) do |os_name, host_json, spec_dir|
  RSpec.describe Kanrisuru::Core::Path do
    include_examples 'path', os_name, host_json, spec_dir
  end
end
