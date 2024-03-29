# frozen_string_literal: true

require File.expand_path('lib/kanrisuru/version', __dir__)

Gem::Specification.new do |gem|
  gem.name        = 'kanrisuru'
  gem.version     = Kanrisuru::VERSION
  gem.author      = 'Ryan Mammina'
  gem.email       = 'ryan@avamia.com'
  gem.license     = 'MIT'
  gem.homepage    = 'https://kanrisuru.com'
  gem.summary     = 'Manage remote servers over ssh with ruby.'
  gem.description = <<-EOF
    Kanrisuru helps manage remote servers with objected oriented ruby.#{' '}
    Results come back as structured data, parsed, prepared and ready.
  EOF

  gem.required_ruby_version = '>= 2.5.0'

  gem.add_development_dependency 'parallel_tests', '~> 3.7'
  gem.add_development_dependency 'rspec', '~> 3.10'
  gem.add_development_dependency 'rubocop', '~> 1.12'
  gem.add_development_dependency 'rubocop-rspec', '~> 2.2'
  gem.add_development_dependency 'simplecov', '~> 0.21'
  gem.add_development_dependency 'simplecov-cobertura', '~> 2.0'

  gem.add_runtime_dependency 'net-ping', '~> 2.0'
  gem.add_runtime_dependency 'net-scp', '~> 3.0'
  gem.add_runtime_dependency 'net-ssh', '~> 6.1'
  gem.add_runtime_dependency 'net-ssh-gateway', '~> 2.0'

  gem.files         = `git ls-files`.split("\n")
  gem.require_paths = ['lib']

  gem.metadata = {
    'source_code_uri' => 'https://github.com/avamia/kanrisuru/',
    'changelog_uri' => 'https://github.com/avamia/kanrisuru/blob/main/CHANGELOG.md',
    'rubygems_mfa_required' => 'true'
  }
end
