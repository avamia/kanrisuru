# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::System do
  before(:all) do
    StubNetwork.stub!
  end

  after(:all) do
    StubNetwork.unstub!
  end

  let(:host) do
    Kanrisuru::Remote::Host.new(
      host: 'localhost',
      username: 'ubuntu',
      keys: ['id_rsa']
    )
  end

  it 'prepares cpu_info command' do
    expect_command(host.cpu_info('sockets'), "lscpu | grep -i '^Socket' | awk '{print $NF}'")
    expect_command(host.cpu_info('cores_per_socket'), "lscpu | grep -i '^Core' | awk '{print $NF}'")
    expect_command(host.cpu_info('threads'), "lscpu | grep -i '^Thread' | awk '{print $NF}'")

    allow(Kanrisuru.logger).to receive(:info)
    expect(Kanrisuru.logger).to receive(:info) do |&block|
      expect(block.call).to eq('DEPRECATION WARNING: cpu_info will be removed in the upcoming major release. Use lscpu instead.')
    end

    expect_command(host.cpu_info('cores'), "lscpu | grep -i '^CPU(' | awk '{print $NF}'")
  end

  it 'prepares free command' do
    expect_command(host.free('total'), "cat /proc/meminfo | grep -i '^MemTotal' | awk '{print $2}'")
    expect_command(host.free('free'), "cat /proc/meminfo | grep -i '^MemFree' | awk '{print $2}'")
    expect_command(host.free('swap'), "cat /proc/meminfo | grep -i '^SwapTotal' | awk '{print $2}'")
    expect_command(host.free('swap_free'), "cat /proc/meminfo | grep -i '^SwapFree' | awk '{print $2}'")

    expect do
      host.free('hello')
    end.to raise_error(ArgumentError)
  end

  it 'prepares kernel_statistics command' do
    expect_command(host.kernel_statistics, 'cat /proc/stat')
  end

  it 'prepares kill command' do
    expect_command(host.kill('KILL', 1024), 'kill -KILL 1024')
    expect_command(host.kill(1, 1024), 'kill -HUP 1024')
    expect_command(host.kill('TERM', [1024, 1025, 1026]), 'kill -TERM 1024 1025 1026')

    expect do
      host.kill('all', 0)
    end.to raise_error(ArgumentError)
  end

  it 'prepares last command' do
    expect_command(host.last, "last -i -F | sed 's/ /  /'")
    expect_command(host.last({ file: '/var/log/login.log' }), "last -i -F -f /var/log/login.log | sed 's/ /  /'")
    expect_command(host.last({ failed_attempts: true }), "lastb -i -F | sed 's/ /  /'")
  end

  it 'prepares load_average command' do
    expect_command(host.load_average, "cat /proc/loadavg | awk '{print $1,$2,$3}'")
  end

  it 'prepares load_env command' do
    expect_command(host.load_env, 'env')
  end

  it 'prepares lscpu command' do
    expect_command(host.lscpu, 'lscpu')
  end

  it 'prepares lsof command' do
    expect_command(host.lsof, 'lsof -F pcuftDsin')
  end

  it 'prepares poweroff command' do
    expect_command(host.poweroff, 'shutdown')
    expect_command(host.poweroff(cancel: true), 'shutdown -c')
    expect_command(host.poweroff(cancel: true, message: 'canceling...'), 'shutdown -c canceling...')
    expect_command(host.poweroff(no_wall: true), 'shutdown --no-wall')
    expect_command(host.poweroff(time: 10), 'shutdown +10')
    expect_command(host.poweroff(time: 'now'), 'shutdown now')
    expect_command(host.poweroff(time: '11:11'), 'shutdown 11:11')
    expect_command(host.poweroff(time: '11:11', message: 'turning off'), 'shutdown 11:11 turning off')

    expect do
      host.poweroff(time: 'hsadf')
    end.to raise_error(ArgumentError)
  end

  it 'prepares ps command' do
    expect_command(host.ps,
                   'ps ww ax -o uid,user,gid,group,ppid,pid,pcpu,pmem,stat,pri,flags,policy,time,cmd --no-headers')
    expect_command(host.ps(user: '1000', group: '1000'),
                   'ps ww --user 1000 --group 1000 -o uid,user,gid,group,ppid,pid,pcpu,pmem,stat,pri,flags,policy,time,cmd --no-headers')
    expect_command(host.ps(user: [0, 1000], group: [0, 1000]),
                   'ps ww --user 0,1000 --group 0,1000 -o uid,user,gid,group,ppid,pid,pcpu,pmem,stat,pri,flags,policy,time,cmd --no-headers')
    expect_command(host.ps(pid: 100),
                   'ps ww --pid 100 -o uid,user,gid,group,ppid,pid,pcpu,pmem,stat,pri,flags,policy,time,cmd --no-headers')
    expect_command(host.ps(pid: [100, 101, 102]),
                   'ps ww --pid 100,101,102 -o uid,user,gid,group,ppid,pid,pcpu,pmem,stat,pri,flags,policy,time,cmd --no-headers')
    expect_command(host.ps(pid: [100, 101, 102], ppid: [0, 3, 5]),
                   'ps ww --pid 100,101,102 --ppid 0,3,5 -o uid,user,gid,group,ppid,pid,pcpu,pmem,stat,pri,flags,policy,time,cmd --no-headers')
  end

  it 'prepares reboot command' do
    expect_command(host.reboot, 'shutdown -r')
    expect_command(host.reboot(cancel: true), 'shutdown -c')
    expect_command(host.reboot(cancel: true, message: 'canceling...'), 'shutdown -c canceling...')
    expect_command(host.reboot(no_wall: true), 'shutdown -r --no-wall')
    expect_command(host.reboot(time: 10), 'shutdown -r +10')
    expect_command(host.reboot(time: 'now'), 'shutdown -r now')
    expect_command(host.reboot(time: '11:11'), 'shutdown -r 11:11')
    expect_command(host.reboot(time: '11:11', message: 'turning off'), 'shutdown -r 11:11 turning off')

    expect do
      host.reboot(time: 'hsadf')
    end.to raise_error(ArgumentError)
  end

  it 'prepares nproc command' do
    expect_command(host.nproc, 'nproc')
    expect_command(host.nproc(all: true), 'nproc --all')
  end

  it 'prepares uptime command' do
    expect_command(host.uptime, 'cat /proc/uptime')
  end

  it 'prepares w command' do
    expect_command(host.w, 'w -hi')
    expect_command(host.who(users: 'centos'), 'w -hi centos')
  end
end
