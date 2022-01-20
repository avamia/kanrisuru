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

  it 'responds to methods' do
    expect(host).to respond_to(:load_env)
    expect(host).to respond_to(:cpu_info)
    expect(host).to respond_to(:lscpu)
    expect(host).to respond_to(:load_average)
    expect(host).to respond_to(:free)
    expect(host).to respond_to(:ps)
    expect(host).to respond_to(:kill)
    expect(host).to respond_to(:kernel_statistics)
    expect(host).to respond_to(:kstat)
    expect(host).to respond_to(:lsof)
    expect(host).to respond_to(:nproc)
    expect(host).to respond_to(:last)
    expect(host).to respond_to(:uptime)
    expect(host).to respond_to(:w)
    expect(host).to respond_to(:who)
    expect(host).to respond_to(:reboot)
    expect(host).to respond_to(:poweroff)
  end

  it 'responds to system fields' do
    expect(Kanrisuru::Core::System::CPUArchitectureVulnerability.new).to respond_to(
      :name,
      :data
    )
    expect(Kanrisuru::Core::System::CPUArchitecture.new).to respond_to(
      :architecture,
      :cores,
      :byte_order,
      :address_sizes,
      :operation_modes,
      :online_cpus,
      :threads_per_core,
      :cores_per_socket,
      :sockets,
      :numa_mode,
      :vendor_id,
      :cpu_family,
      :model,
      :model_name,
      :stepping,
      :cpu_mhz,
      :cpu_max_mhz,
      :cpu_min_mhz,
      :bogo_mips,
      :virtualization,
      :hypervisor_vendor,
      :virtualization_type,
      :l1d_cache,
      :l1i_cache,
      :l2_cache,
      :l3_cache,
      :numa_nodes,
      :vulnerabilities,
      :flags
    )
    expect(Kanrisuru::Core::System::KernelStatisticCpu.new).to respond_to(
      :user,
      :nice,
      :system,
      :idle,
      :iowait,
      :irq,
      :softirq,
      :steal,
      :guest,
      :guest_nice
    )
    expect(Kanrisuru::Core::System::KernelStatistic.new).to respond_to(
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
    expect(Kanrisuru::Core::System::ProcessInfo.new).to respond_to(
      :uid, :user, :gid, :group, :ppid, :pid,
      :cpu_usage, :memory_usage, :stat, :priority,
      :flags, :policy_abbr, :policy, :cpu_time, :command
    )
    expect(Kanrisuru::Core::System::Uptime.new).to respond_to(
      :boot_time, :uptime, :seconds, :minutes, :hours, :days
    )
    expect(Kanrisuru::Core::System::UserLoggedIn.new).to respond_to(
      :user, :tty, :ip, :login, :idle, :jcpu, :pcpu, :command
    )
    expect(Kanrisuru::Core::System::OpenFile.new).to respond_to(
      :command,
      :pid,
      :uid,
      :file_descriptor,
      :type,
      :device,
      :fsize,
      :inode,
      :name
    )
    expect(Kanrisuru::Core::System::SessionDetail.new).to respond_to(
      :tty,
      :login_at,
      :logout_at,
      :ip_address,
      :success
    )

    expect(Kanrisuru::Core::System::LoginUser.new).to respond_to(
      :user,
      :sessions
    )
  end
end
