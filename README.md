<h1>
  <img src="./logo/kanrisuru-logo.png" alt="Kanrisuru" width="515" height="100%"/>  
</h1>

<p>
  <a href="https://rubygems.org/gems/kanrisuru">
    <img src="https://img.shields.io/gem/v/kanrisuru?style=flat-square" alt="Latest version" />
  </a> 
  <a href="https://github.com/avamia/kanrisuru/blob/main/LICENSE.txt">
    <img src="https://img.shields.io/github/license/avamia/kanrisuru?style=flat-square" alt="Latest version" />
  </a> 
  <img src="https://img.shields.io/github/repo-size/avamia/kanrisuru?style=flat-square" alt="GitHub repo size" />
  <img src="https://img.shields.io/codecov/c/gh/avamia/kanrisuru?token=2Q1BE106B2&style=flat-square" alt="Codecov" /> 
  <img src="https://img.shields.io/codacy/grade/9e839eb160bc445ea4e81b64cef22b27?style=flat-square" alt="Codacy grade" />
  <img src="https://img.shields.io/codeclimate/maintainability/avamia/kanrisuru?style=flat-square" alt="Code Climate maintainability" />
</p>

Kanrisuru (manage) helps you remotely control infrastructure using Ruby. This is done over SSH. I'm working on building up some basic functionality to help quickly provision, deploy and manage a single host or cluster of hosts.

The idea behind this project is not to replace the numerous other projects to manage your infrastrucutre, however, I've found there usually meant to be a standalone project that have their own ecosystem. With Kanrisuru, you essentailly plug the library directly into your ruby project.

At this point, Kanrisuru doesn't use a DSL, or offer idempotency, and while that may be added later on, the goal with this project is to expose helpful ways of managing your remote infrastructure with plain ruby in a procedural manner. The realization I had was when trying to deal with other open source projects, you either had to deal with a different language than ruby, use agents on remote hosts, or deal with a complex library that is meant to act in a declarative manner.

If you want to dynamically interact with a host, eg: If you need to dynamically scale your infrastructure by continually monitoring specific stats from a centralized system, Kanrisuru can help you accomplish this.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kanrisuru'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install kanrisuru
```

## Usage
Run basic commands you would have access to while running on a remote host or on a cluster of hosts.

### Host
```ruby
host = Kanrisuru::Remote::Host.new(host: 'host', username: 'ubuntu', keys: ['~/.ssh/id_rsa'])
result = host.whoami   
result.to_s						# => 'ubuntu'

result = host.pwd
result.path 					# => /home/ubuntu 
```

### Cluster 
```ruby
cluster = Kanrisuru::Remote::Cluster.new({
  host: 'host1', username: 'ubuntu', keys: ['~/.ssh/id_rsa']
}, {
  host: 'host2', username: 'alice', keys: ['~/.ssh/id_rsa']
})

cluster.whoami   # => {host: 'host1', result: 'ubuntu'}, {host: 'host2', result: 'alice'}
cluster.pwd      # => {host: 'host1', result: '/home/ubuntu'}, {host: 'host2', result: '/home/alice'}

cluster.each do |host|
  host.pwd.path  # => /home/ubuntu
end
```

### Host or Cluster with underlying command
```ruby
host = Kanrisuru::Remote::Host.new(host: 'host1', username: 'ubuntu', keys: ['~/.ssh/id_rsa'])

command = Kanrisuru::Command.new('uname')
host.execute(command)

command.success? #=> true
command.to_s  #=> Linux

cluster = Kanrisuru::Remote::Cluster.new(host, {host: 'host2', username: 'alice', keys: ['~/.ssh/id_rsa']})

cluster.execute('uname') #=> {host: 'host1', result: 'Linux'}, {host: 'host2', result: 'Linux'}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. 


To test kanrisuru across various linux distros, update your local `/etc/hosts` file to create an alias to the local virtual machine with that distro type. You can also set the host alias to the localhost machine.

To select which hosts to run rspec across, prepend the command line or export the variable while running rspec.

```bash
HOSTS=ubuntu,debian,centos rspec
```

This will run tests on the ubuntu, debian and centos instances.

Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/avamia/kanrisuru. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/avamia/kanrisuru/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Kanrisuru project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/avamia/kanrisuru/blob/master/CODE_OF_CONDUCT.md).
