# frozen_string_literal: true

require File.expand_path('lib/kanrisuru/version', __dir__)

Gem::Specification.new do |gem|
  gem.name        = 'kanrisuru'
  gem.version     = Kanrisuru::VERSION
  gem.author      = 'Ryan Mammina'
  gem.email       = 'ryan@avamia.com'
  gem.license     = 'MIT'
  gem.summary     = 'Manage remote servers over ssh with ruby.'
  gem.homepage    = 'https://github.com/avamia/kanrisuru'

  gem.required_ruby_version     = '>= 2.5.0'
  gem.required_rubygems_version = '>= 1.8.11'

  gem.add_development_dependency 'rspec', '>= 3.10.0'
  gem.add_development_dependency 'rubocop', '>= 1.12.1'
  gem.add_development_dependency 'rubocop-rspec', '>= 2.2.0'
  gem.add_development_dependency 'simplecov', '>= 0.21.2'

  gem.add_runtime_dependency 'net-ping', '>= 2.0.8'
  gem.add_runtime_dependency 'net-scp', '>= 3.0.0'
  gem.add_runtime_dependency 'net-ssh', '>= 6.1.0'

  gem.files         = `git ls-files`.split("\n")
  gem.require_paths = ['lib']

  gem.metadata = {
    'source_code_uri' => 'https://github.com/avamia/kanrisuru/'
  }
end
