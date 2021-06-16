# frozen_string_literal: true

require File.expand_path('lib/kanrisuru/version', __dir__)

Gem::Specification.new do |gem|
  gem.name        = 'kanrisuru'
  gem.version     = Kanrisuru::VERSION
  gem.author      = 'Ryan Mammina'
  gem.email       = 'ryan@avamia.com'
  gem.license     = 'MIT'
  gem.summary     = 'Manage remote servers with ruby.'
  gem.homepage    = 'https://github.com/avamia/kanrisuru'

  gem.required_ruby_version     = '>= 2.5.0'
  gem.required_rubygems_version = '>= 1.8.11'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'rubocop-rspec'
  gem.add_development_dependency 'simplecov'

  gem.add_runtime_dependency 'net-ping'
  gem.add_runtime_dependency 'net-scp'
  gem.add_runtime_dependency 'net-ssh'

  gem.files         = `git ls-files`.split("\n")
  gem.require_paths = ['lib']

  gem.metadata = {
    'source_code_uri' => 'https://github.com/avamia/kanrisuru/'
  }
end
