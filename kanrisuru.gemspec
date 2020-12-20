require File.expand_path('../lib/kanrisuru/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "kanrisuru"
  gem.version     = Kanrisuru::VERSION
  gem.authors     = ["Ryan Mammina"]
  gem.email       = ["ryan@avamia.com"]
  gem.license     = "MIT"

  gem.summary     = "Manage remote servers with ruby and ssh."
  gem.description = "Manage remote servers with ruby and ssh."

  gem.homepage    = "https://github.com/avamia-dm/kanrisuru"
  
  gem.add_runtime_dependency 'net-scp'
  gem.add_runtime_dependency 'net-sftp'
  gem.add_runtime_dependency 'net-ssh'

  gem.files         = `git ls-files`.split("\n")
  gem.require_paths = ["lib"]

  gem.rubyforge_project = 'nowarning'
end
