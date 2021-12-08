# frozen_string_literal: true

module Kanrisuru
  module Core
    module System
      CPUArchitectureVulnerability = Struct.new(
        :name,
        :data
      )

      CPUArchitecture = Struct.new(
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

      KernelStatisticCpu = Struct.new(
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

      KernelStatistic = Struct.new(
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

      ProcessInfo = Struct.new(
        :uid, :user, :gid, :group, :ppid, :pid,
        :cpu_usage, :memory_usage, :stat, :priority,
        :flags, :policy_abbr, :policy, :cpu_time, :command
      )

      Uptime = Struct.new(
        :boot_time, :uptime, :seconds, :minutes, :hours, :days
      )

      UserLoggedIn = Struct.new(:user, :tty, :ip, :login, :idle, :jcpu, :pcpu, :command)

      OpenFile = Struct.new(
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

      SessionDetail = Struct.new(
        :tty,
        :login_at,
        :logout_at,
        :ip_address,
        :success
      )

      LoginUser = Struct.new(
        :user,
        :sessions
      )
    end
  end
end
