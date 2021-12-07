# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'system' do |os_name, host_json, _spec_dir|
  context "with #{os_name}" do
    let(:host) do
      Kanrisuru::Remote::Host.new(
        host: host_json['hostname'],
        username: host_json['username'],
        keys: [host_json['ssh_key']]
      )
    end

    after do
      host.disconnect
    end

    it 'gets cpu details' do
      result = host.lscpu
      expect(result).to be_success
      expect(result.data).to be_instance_of(Kanrisuru::Core::System::CPUArchitecture)
    end

    it 'gets environment variables' do
      result = host.load_env
      expect(result).to be_success
      expect(result.data).to be_instance_of(Hash)
    end

    it 'gets open files' do
      host.su('root')
      result = host.lsof
      expect(result).to be_success
      expect(result.data).to be_instance_of(Array)
    end

    it 'gets uptime' do
      result = host.uptime
      expect(result).to be_success

      expect(result).to respond_to(
        :boot_time, :uptime, :seconds,
        :hours, :minutes, :days
      )

      expect(result.seconds).to be > 0
      expect(result.minutes).to be >= 0
      expect(result.hours).to be >= 0
      expect(result.days).to be >= 0
    end

    it 'kills pids' do
      command = 'sleep 100000 > /dev/null 2>&1 &'

      host.execute_shell("nohup #{command}")
      result = host.ps(user: host_json['username'])
      expect(result.success?).to eq(true)

      process = result.select do |proc|
        proc.command == 'sleep 100000'
      end

      pids = process.map(&:pid)
      result = host.kill('SIGKILL', pids)
      expect(result.success?).to eq(true)

      result = host.ps(user: host_json['username'])
      process = result.select do |proc|
        proc.command == 'sleep 100000'
      end

      expect(process).to be_empty
    end

    it 'gets kernel statistics' do
      result = host.kernel_statistics
      expect(result).to be_success

      expect(result.data).to respond_to(
        :cpu_total,
        :cpus,
        :interrupt_total,
        :interrupts,
        :ctxt,
        :btime,
        :processes,
        :procs_running,
        :procs_blocked,
        :softirq_total,
        :softirqs
      )

      expect(result.cpus.length).to eq(host.cpu.cores)
    end

    it 'gets login details' do
      host.su('root')

      result = host.last
      expect(result).to be_success
    end

    it 'gets failed login attempts' do
      host.su('root')

      result = host.last(failed_attempts: true)
      expect(result).to be_success
    end

    it 'gets process details' do
      result = host.ps

      expect(result.data).to be_instance_of(Array)
      process = result[0]

      expect(process).to respond_to(
        :uid, :user, :gid, :group,
        :pid, :ppid, :cpu_usage, :memory_usage,
        :stat, :priority, :flags, :policy_abbr, :policy,
        :cpu_time, :command
      )

      result = host.ps(user: [host_json['username']])

      expect(result.data).to be_instance_of(Array)

      process = result.find do |proc|
        proc.command == result.command.raw_command
      end

      expect(process.command).to eq(result.command.raw_command)
    end

    it 'gets information for users' do
      result = host.who
      expect(result.success?).to eq(true)
    end

    it 'cancels rebooting system' do
      host.su('root')
      result = host.reboot(time: 1000)
      expect(result).to be_success

      result = host.reboot(cancel: true)
      expect(result).to be_success

      result = host.reboot(time: '11:11', message: 'Rebooting system')
      expect(result).to be_success

      result = host.reboot(cancel: true)
      expect(result).to be_success
    end
  end
end
