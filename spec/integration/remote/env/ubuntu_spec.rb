# frozen_string_literal: true

require 'spec_helper'

TestHosts.each_os(only: %w[ubuntu]) do |os_name, host_json, spec_dir|
  RSpec.describe Kanrisuru::Remote::Env do
    include_examples 'env', os_name, host_json, spec_dir
  end
end
