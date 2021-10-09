[![Latest version](https://img.shields.io/gem/v/kanrisuru?style=flat-square)](https://rubygems.org/gems/kanrisuru)&nbsp;
[![Latest version](https://img.shields.io/github/license/avamia/kanrisuru)](https://github.com/avamia/kanrisuru/blob/main/LICENSE.txt)&nbsp;
![GitHub repo size](https://img.shields.io/github/repo-size/avamia/kanrisuru)&nbsp;

<p align='center'>
  <img src="https://s3.us-east-2.amazonaws.com/kanrisuru.com/kanrisuru-banner-02.png" width="600" />
</p>

# Kanrisuru

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

    $ bundle install

Or install it yourself as:

    $ gem install kanrisuru

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

## Methods and Testing 

| Description                           | Ruby             | Shell              | Module | Man                                  | Debian | Ubuntu | Fedora | Centos | RHEL | openSUSE | SLES |
|---------------------------------------|------------------|--------------------|--------|--------------------------------------|--------|--------|--------|--------|------|----------|------|
| **System**                            |                  |                    |        |                                      |        |        |        |        |      |          |      |
| Get CPU Info                          | cpu_info         | lscpu              | core   | https://linux.die.net/man/1/lscpu    | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Get CPU architecture                          |  lscpu         | lscpu            | core   | https://linux.die.net/man/1/lscpu    | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Get kernel stastics                          |  kernel_statistics         | cat /proc/stat            | core   |   | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Get hardware BIOS info                          |  dmi         | dmidecode            | core   | https://linux.die.net/man/8/dmidecode  | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Get open file details for processes                          |  lsof         | lsof            | core   | https://linux.die.net/man/8/lsof  | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Get Load Average                      | load_average     | cat /proc/load_avg | core   |                                      | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Get RAM Available                     | free             | cat /proc/meminfo  | core   |                                      | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Get list of processes                 | ps               | ps                 | core   | https://linux.die.net/man/1/ps       | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Get Env vars                          | load_env         | env                | core   |                                      | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Kill process                          | kill             | kill               | core   | https://linux.die.net/man/1/kill     | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Get uptime of system                  | uptime           | cat /proc/uptime   | core   | https://linux.die.net/man/1/uptime   | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Get who's logged in                   | w                | w                  | core   | https://linux.die.net/man/1/w        | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Reboot machine                        | reboot           | shutdown           | core   | https://linux.die.net/man/8/reboot   | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Poweroff machine                      | poweroff         | shutdown           | core   | https://linux.die.net/man/8/shutdown | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| **Disk**                              |                  |                    |        |                                      |        |        |        |        |      |          |      |
| Get Disk Space                        | df               | df                 | core   | https://linux.die.net/man/1/df       | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Get Disk Usage                        | du               | du                 | core   | https://linux.die.net/man/1/du       | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| List block devices                    | lsblk            | lsblk              | core   | https://linux.die.net/man/8/lsblk    | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Get block device attributes           | blkid            | blikd              | core   | https://linux.die.net/man/8/blkid    | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| **Mount**                             |                  |                    |        |                                      |        |        |        |        |      |          |      |
| Mount a filesystem                    | mount            | mount              | core   | https://linux.die.net/man/8/mount    |        |        |        |        |      |          |      |
| Unmount a filesystem                  | umount           | umount             | core   | https://linux.die.net/man/8/umount   |        |        |        |        |      |          |      |
| **Group**                             |                  |                    |        |                                      |        |        |        |        |      |          |      |
| Get Group Id                          | get_gid          | getent group       | core   | https://linux.die.net/man/1/getent   | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Get Group                             | get_group        | grep /etc/group    | core   |                                      | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Create Group                          | create_group     | groupadd           | core   | https://linux.die.net/man/8/groupadd | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Update Group                          | update_group     | groupmod           | core   | https://linux.die.net/man/8/groupmod | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Delete Group                          | delete_group     | groupdel           | core   | https://linux.die.net/man/8/groupdel | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| **User**                              |                  |                    |        |                                      |        |        |        |        |      |          |      |
| Get User Id                           | get_uid          | id -u              | core   | https://linux.die.net/man/1/id       | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Get User                              | get_user         | id                 | core   | https://linux.die.net/man/1/id       | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Create User                           | create_user      | useradd            | core   | https://linux.die.net/man/8/useradd  | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Update User                           | update_user      | usermod            | core   | https://linux.die.net/man/8/usermod  | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Delete User                           | delete_user      | userdel            | core   | https://linux.die.net/man/8/userdel  | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| **Path**                              |                  |                    |        |                                      |        |        |        |        |      |          |      |
| List files and directories            | ls               | ls                 | core   | https://linux.die.net/man/1/ls       | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Get Current Dir                       | pwd              | pwd                | core   | https://linux.die.net/man/1/pwd      | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Get Current User                      | whoami           | whoami             | core   | https://linux.die.net/man/1/whoami   | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Get Full Path of Shell Command        | which            | which              | core   | https://linux.die.net/man/1/which    | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Real Path                             | realpath         | realpath           | core   | https://linux.die.net/man/1/realpath | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Read link                             | readlink         | readlink           | core   | https://linux.die.net/man/1/readlink | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Change Dir                            | cd               | cd                 | core   |                                      | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| **File**                              |                  |                    |        |                                      |        |        |        |        |      |          |      |
| "Find file, dir, special file device" | find             | find               | core   | https://linux.die.net/man/1/find     | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Stat file info                        | stat             | stat               | core   | https://linux.die.net/man/1/stat     | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Change Permission of file / folder    | chmod            | chmod              | core   | https://linux.die.net/man/1/chmod    | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Change Ownership of file / folder     | chown            | chown              | core   | https://linux.die.net/man/1/chown    | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Hard Link File                        | ln               | ln                 | core   | https://linux.die.net/man/1/ln       | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Soft Link File / Dir                  | ln_s             | ln                 | core   | https://linux.die.net/man/1/ln       | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Create Directory                      | mkdir            | mkdir              | core   | https://linux.die.net/man/1/mkdir    | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Remove file / directory               | rm               | rm                 | core   | https://linux.die.net/man/1/rm       | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Remove Directory                      | rmdir            | rm                 | core   | https://linux.die.net/man/1/rm       | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Touch File                            | touch            | touch              | core   | https://linux.die.net/man/1/touch    | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Copy file / directory                 | cp               | cp                 | core   | https://linux.die.net/man/1/cp       | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Move file / directory                 | mv               | mv                 | core   | https://linux.die.net/man/1/mv       | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| "Get file line, word, and char count" | wc               | wc                 | core   | https://linux.die.net/man/1/wc       | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| **Stream**                            |                  |                    |        |                                      |        |        |        |        |      |          |      |
| Get content from beginning of file    | head             | head               | core   | https://linux.die.net/man/1/head     | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Get content from end of file          | tail             | tail               | core   | https://linux.die.net/man/1/tail     | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Read a chunk from a file by lines     | reach_file_chunk | tail and head      | core   |                                      | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Echo to stdout or to file             | echo             | echo               | core   | https://linux.die.net/man/1/echo     | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Get all content from a file           | cat              | cat                | core   | https://linux.die.net/man/1/cat      | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Sed                                   | sed              | sed                | core   | https://linux.die.net/man/1/sed      | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| **Archive**                           |                  |                    |        |                                      |        |        |        |        |      |          |      |
| Tar Files                             | tar              | tar                | core   | https://linux.die.net/man/1/tar      | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| **Network**                           |                  |                    |        |                                      |        |        |        |        |      |          |      |
| Manage network devices                | ip               | ip                 | core   | https://linux.die.net/man/8/ip       | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Get Socket Details                    | ss               | ss                 | core   | https://linux.die.net/man/8/ss       | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| **Transfer**                          |                  |                    |        |                                      |        |        |        |        |      |          |      |
| Upload to remote server               | upload           | scp                | core   | https://linux.die.net/man/1/scp      | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Download from remote server           | download         | scp                | core   | https://linux.die.net/man/1/scp      | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| Wget                                  | wget             | wget               | core   | https://linux.die.net/man/1/wget     | [x]    | [x]    | [x]    | [x]    | [x]  | [x]      | [x]  |
| **Packages**                          |                  |                    |        |                                      |        |        |        |        |      |          |      |
| Apt               | apt           | apt                | core   | https://linux.die.net/man/1/apt      | [x]    | [x]    |    |    |  |      |  |
| Yum           | yum         | yum                | core   | https://linux.die.net/man/1/yum      |    |    | [x]    | [x]    | [x]  |      |  |
| Zypper           | zypper         | zypper                | core   | https://en.opensuse.org/SDB:Zypper_manual   |    |    |   |    |  | [x] | [x] |

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
