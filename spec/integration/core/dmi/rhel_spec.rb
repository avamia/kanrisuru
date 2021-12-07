# frozen_string_literal: true

require 'spec_helper'

TestHosts.each_os(only: %w[rhel]) do |os_name, host_json|
  RSpec.describe Kanrisuru::Core::Dmi do
    include_examples 'dmi', os_name, host_json
  end
end
