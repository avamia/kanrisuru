# frozen_string_literal: true

require 'spec_helper'

TestHosts.each_os(only: %w[opensuse]) do |os_name, host_json, spec_dir|
  RSpec.describe Kanrisuru::Core::Transfer do
    include_examples 'transfer', os_name, host_json, spec_dir
  end
end
