<h1>
  <img src="https://s3.us-east-2.amazonaws.com/kanrisuru.com/kanrisuru-logo.png" alt="Kanrisuru" width="400" height="100%"/>  
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

Kanrisuru manages remote infrastructure with plain ruby objects. The goal with Kanrisuru is to provide a clean objected oriented wrapper over the most commonly used linux commands, with a clean command interface, and with any usable output, present that as parsed structured data. Kanrisuru doesn't use remote agents to run commands on hosts, nor does the project rely on a large complex set of dependencies.

## Getting Started

Kanrisuru requires ruby `2.5.0` at a minimum.

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

## Documentation
You can find the official documentation https://kanrisuru.com

## Usage Guide
### Host
To connect with Kanrisuru to a remote host, provide the login credentials to instantiate a `Kanrisuru::Remote::Host` instance.

```ruby
host = Kanrisuru::Remote::Host.new(
  host: 'remote-host-name', 
  username: 'ubuntu', 
  keys: ['~/.ssh/id_rsa']
)
```

#### Connect with a Jump / Bastion Host
To connect to a host behind a firewall through a jump / bastion host, pass either an instance of another Kanrisuru::Remote::Host, or a hash of host config values

```ruby
proxy = Kanrisuru::Remote::Host.new(
  host: 'proxy-host',
  username: 'ubuntu',
  keys: ['~/.ssh/proxy.pem']
)

host = Kanrisuru::Remote::Host.new(
  host: '1.2.3.4', 
  username: 'ubuntu', 
  keys: ['~/.ssh/id_rsa'],
  proxy: proxy
)

host.whoami
'ubuntu'
```

#### run a simple echo command on the remote host
```ruby
host.env['VAR'] = 'world'
result = host.echo('hello $VAR')
result.success?
true

result.to_s
'hello world'
```

#### build a custom command
```ruby
command = Kanrisuru::Command.new('wc')
command << '/home/ubuntu/file1.txt'

host.execute_shell(command)
result = Kanrisuru::Result.new(command) do |cmd|
  items = cmd.to_s.split
  
  struct = Kanrisuru::Core::File::FileCount.new
  struct.lines = items[0]
  struct.words = items[1]
  struct.characters = items[2]
  struct
end
```
The `Kanrisuru::Result` class will only run the parsing block if the command run on the remote host was succeful. The final line will be used to build the result object to be read easily. This instance will also dynamically add getter methods to read the underlying data struct for easier querying capabiltiies.

```ruby
result.success?
true

result.lines
8

result.characters
150

result.words
85
```

### Cluster
Kanrisuru can manage multiple hosts at the same time with the `Kanrisuru::Remote::Cluster`.

#### To instantiate a cluster, add 1 or more hosts:
```ruby
cluster = Kanrisuru::Remote::Cluster.new({
  host: 'remote-host-1',
  username: 'ubuntu',
  keys: ['~/.ssh/remote_1_id_rsa']
}, {
  host: 'remote-host-2',
  username: 'centos',
  keys: ['~/.ssh/remote_2_id_rsa']
}, {
  host: 'remote-host-3',
  username: 'opensuse',
  keys: ['~/.ssh/remote_3_id_rsa']
})
```

#### You can also add a host to a cluster that's already been created 
```ruby
host = Kanrisuru::Remote::Host.new(host: 'remote-host-4', username: 'rhel', keys: ['~/.ssh/remote_4_id_rsa'])

cluster << host 
```

Kanrisuru at this point only runs commands sequentially. We plan on creating a parallel run mode in a future release.

#### To run across all hosts with a single command, cluster will return a array of result hashes
```ruby
cluster.whoami
[
  {
    :host => "remote-host-1",
    :result => #<Kanrisuru::Result:0x640 @status=0 @data=#<struct Kanrisuru::Core::Path::UserName user="ubuntu"> @command=sudo -u ubuntu /bin/bash -c "whoami">
  },
  {
    :host => "remote-host-2",
    :result => #<Kanrisuru::Result:0x700 @status=0 @data=#<struct Kanrisuru::Core::Path::UserName user="centos"> @command=sudo -u centos /bin/bash -c "whoami">
  },
  {
    :host => "remote-host-3",
    :result => #<Kanrisuru::Result:0x760 @status=0 @data=#<struct Kanrisuru::Core::Path::UserName user="opensuse"> @command=sudo -u opensuse /bin/bash -c "whoami">
  },
  {
    :host => "remote-host-4",
    :result => #<Kanrisuru::Result:0x820 @status=0 @data=#<struct Kanrisuru::Core::Path::UserName user="rhel"> @command=sudo -u rhel /bin/bash -c "whoami">
  }
]
```

#### You can also access each host individually to run a command conditionaly within an iterable block
```ruby
cluster.each do |host|
  case host.os.release
  when 'ubuntu', 'debian'
    host.apt('update')
  when 'centos', 'redhat', 'fedora'
    host.yum('update')
  when 'opensuse_leap', 'sles'
    host.zypper('update')
  end
end
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
