# frozen_string_literal: true

require 'spec_helper'

TestHosts.each_os(only: %w[debian]) do |os_name, host_json, spec_dir|
  RSpec.describe Kanrisuru::Remote::File do
    include_examples 'remote_file', os_name, host_json, spec_dir
  end
end
