# frozen_string_literal: true

require 'spec_helper'

TestHosts.each_os(only: %w[centos]) do |os_name, host_json, spec_dir|
  RSpec.describe Kanrisuru::Core::Archive do
    include_examples "archive", os_name, host_json, spec_dir
  end
end
