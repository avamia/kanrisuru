# frozen_string_literal: true

require_relative 'helper/simplecov'

Dir[ './spec/support/**/*.rb'].each { |f| require(f) }

require 'kanrisuru'

require_relative 'helper/test_hosts'
require_relative 'helper/stub_network'
require_relative 'helper/expect_helpers'

Kanrisuru.logger.level = Logger::WARN

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.silence_filter_announcements = true if ENV['TEST_ENV_NUMBER']

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
