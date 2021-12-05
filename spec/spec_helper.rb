# frozen_string_literal: true

require 'simplecov'
require 'simplecov-cobertura'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::CoberturaFormatter
])

SimpleCov.use_merging true 
SimpleCov.command_name("kanrisuru-tests" + (ENV['TEST_ENV_NUMBER'] || ''))

SimpleCov.start

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
