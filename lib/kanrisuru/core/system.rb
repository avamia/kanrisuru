# frozen_string_literal: true

require 'date'

module Kanrisuru
  module Core
    module System
      extend OsPackage::Define

      os_define :linux, :load_env
      os_define :linux, :cpu_info
      os_define :linux, :lscpu
      os_define :linux, :load_average
      os_define :linux, :free
      os_define :linux, :ps
      os_define :linux, :kill

      os_define :linux, :kernel_statistics

      os_define :linux, :uptime

      os_define :linux, :w
      os_define :linux, :who

      os_define :linux, :reboot
      os_define :linux, :poweroff

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

      def load_env
        command = Kanrisuru::Command.new('env')
        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          string = cmd.to_s
          hash = {}

          rows = string.split("\n")
          rows.each do |row|
            key, value = row.split('=', 2)
            hash[key] = value
          end

          hash
        end
      end

      def lscpu
        command = Kanrisuru::Command.new('lscpu')

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a

          result = CPUArchitecture.new
          result.vulnerabilities = []
          result.numa_nodes = []

          lines.each do |line|
            values = line.split(': ', 2)

            field = values[0].strip
            data = values[1].strip

            case field
            when 'Architecture'
              result.architecture = data
            when 'CPU op-mode(s)'
              result.operation_modes = data.split(', ')
            when 'Byte Order'
              result.byte_order = data
            when 'Address sizes'
              result.address_sizes = data.split(', ')
            when 'CPU(s)'
              result.cores = data.to_i
            when 'On-line CPU(s) list'
              result.online_cpus = data.to_i
            when 'Thread(s) per core'
              result.threads_per_core = data.to_i
            when 'Core(s) per socket'
              result.cores_per_socket = data.to_i
            when 'Socket(s)'
              result.sockets = data.to_i
            when 'NUMA node(s)'
              result.numa_nodes = data.to_i
            when 'Vendor ID'
              result.vendor_id = data
            when 'CPU family'
              result.cpu_family = data.to_i
            when 'Model'
              result.model = data.to_i
            when 'Model name'
              result.model_name = data
            when 'Stepping'
              result.stepping = data.to_i
            when 'CPU MHz'
              result.cpu_mhz = data.to_f
            when 'CPU max MHz'
              result.cpu_max_mhz = data.to_f
            when 'CPU min MHz'
              result.cpu_min_mhz = data.to_f
            when 'CPUBogoMIPS'
              result.bogo_mips = data.to_f
            when 'Virtualization'
              result.virtualization = data
            when 'Hypervisor vendor'
              result.hypervisor_vendor = data
            when 'Virtualization type'
              result.virtualization_type = data
            when 'L1d cache'
              result.l1d_cache = data
            when 'L1i cache'
              result.l1i_cache = data
            when 'L2 cache'
              result.l2_cache = data
            when 'L3 cache'
              result.l3_cache = data
            when /^Numa node/
              result.numa_nodes << data.split(',')
            when /^Vulnerability/
              name = field.split('Vulnerability ')[1]
              result.vulnerabilities << CPUArchitectureVulnerability.new(name, data)
            when 'Flags'
              result.flags = data.split
            end
          end

          result
        end
      end

      def cpu_info(spec)
        name =
          case spec
          when 'sockets'
            '^Socket'
          when 'cores_per_socket'
            '^Core'
          when 'threads'
            '^Thread'
          when 'cores'
            '^CPU('
          else
            return
          end

        command = Kanrisuru::Command.new("lscpu | grep -i '#{name}' | awk '{print $NF}'")
        execute(command)

        Kanrisuru::Result.new(command, &:to_i)
      end

      def load_average
        command = Kanrisuru::Command.new("cat /proc/loadavg | awk '{print $1,$2,$3}'")
        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          cmd.to_s.split.map(&:to_f)
        end
      end

      def free(type)
        conversions = {
          total: 'MemTotal',
          free: 'MemFree',
          swap: 'SwapTotal',
          swap_free: 'SwapFree'
        }

        option = conversions[type.to_sym]
        raise ArgumentError, 'Invalid mem type' unless option

        command = Kanrisuru::Command.new("cat /proc/meminfo | grep -i '^#{option}' | awk '{print $2}'")
        execute(command)

        ## In kB
        Kanrisuru::Result.new(command, &:to_i)
      end

      def ps(opts = {})
        group = opts[:group]
        user  = opts[:user]
        pid   = opts[:pid]
        ppid  = opts[:ppid]
        # tree  = opts[:tree]

        command = Kanrisuru::Command.new('ps ww')

        if !user.nil? || !group.nil? || !pid.nil? || !ppid.nil?
          command.append_arg('--user', user.instance_of?(Array) ? user.join(',') : user)
          command.append_arg('--group', group.instance_of?(Array) ? group.join(',') : group)
          command.append_arg('--pid', pid.instance_of?(Array) ? pid.join(',') : pid)
          command.append_arg('--ppid', ppid.instance_of?(Array) ? ppid.join(',') : ppid)
        else
          command.append_flag('ax')
        end

        command.append_arg('-o', 'uid,user,gid,group,ppid,pid,pcpu,pmem,stat,pri,flags,policy,time,cmd')
        command.append_flag('--no-headers')

        execute(command)

        ## Have found issues with regular newline parsing from command
        ## most likely a buffer overflow from SSH buffer.
        ## Join string then split by newline.
        Kanrisuru::Result.new(command) do |cmd|
          result_string = cmd.raw_result.join
          rows = result_string.split("\n")

          build_process_list(rows)
        end
      end

      def kill(signal, pids)
        raise ArgumentError, 'Invalid signal' unless Kanrisuru::Util::Signal.valid?(signal)

        ## Use named signals for readabilitiy
        signal = Kanrisuru::Util::Signal[signal] if signal.instance_of?(Integer)

        command = Kanrisuru::Command.new('kill')
        command << "-#{signal}"
        command << (pids.instance_of?(Array) ? pids.join(' ') : pids)

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def kernel_statistics
        command = Kanrisuru::Command.new('cat /proc/stat')

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          lines = cmd.to_a

          result = KernelStatistic.new
          result.cpus = []

          lines.each do |line|
            values = line.split
            field = values[0]
            values = values[1..-1].map(&:to_i)

            case field
            when /^cpu/
              cpu_stat = KernelStatisticCpu.new
              cpu_stat.user = values[0]
              cpu_stat.nice = values[1]
              cpu_stat.system = values[2]
              cpu_stat.idle = values[3]
              cpu_stat.iowait = values[4]
              cpu_stat.irq = values[5]
              cpu_stat.softirq = values[6]
              cpu_stat.steal = values[7]
              cpu_stat.guest = values[8]
              cpu_stat.guest_nice = values[9]

              case field
              when /^cpu$/
                result.cpu_total = cpu_stat
              when /^cpu\d+/
                result.cpus << cpu_stat
              end
            when 'intr'
              result.interrupt_total = values[0]
              result.interrupts = values[1..-1]
            when 'softirq'
              result.softirq_total = values[0]
              result.softirqs = values[1..-1]
            else
              result[field] = values[0]
            end
          end

          result
        end
      end

      def uptime
        ## Ported from https://github.com/djberg96/sys-uptime
        command = Kanrisuru::Command.new('cat /proc/uptime')

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          seconds = cmd.to_s.split[0].to_i
          minutes = seconds / 60
          hours = seconds / 3600
          days = seconds / 86_400

          seconds_dur = seconds
          days_dur = seconds_dur / 86_400
          seconds_dur -= days_dur * 86_400
          hours_dur = seconds_dur / 3600
          seconds_dur -= hours_dur * 3600
          minutes_dur = seconds_dur / 60
          seconds_dur -= minutes_dur * 60
          uptime_s = "#{days_dur}:#{hours_dur}:#{minutes_dur}:#{seconds_dur}"

          boot_time = Time.now - seconds

          Uptime.new(
            boot_time,
            uptime_s,
            seconds,
            minutes,
            hours,
            days
          )
        end
      end

      def w(opts = {})
        users = opts[:users]
        command = Kanrisuru::Command.new('w -hi')

        command << users if Kanrisuru::Util.present?(users)

        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          result_string = cmd.raw_result.join
          rows = result_string.split("\n")

          rows.map do |row|
            values = *row.split(/\s+/, 8)
            UserLoggedIn.new(
              values[0],
              values[1],
              IPAddr.new(values[2]),
              values[3],
              values[4],
              values[5].to_f,
              values[6].to_f,
              values[7]
            )
          end
        end
      end

      def who(opts = {})
        w(opts)
      end

      def reboot(opts = {})
        time = opts[:time]
        cancel = opts[:cancel]
        message = opts[:message]
        no_wall = opts[:no_wall]

        command = Kanrisuru::Command.new('shutdown')

        if Kanrisuru::Util.present?(cancel)
          command.append_flag('-c')
          command << message if message
        else
          command.append_flag('-r')

          time = format_shutdown_time(time) if Kanrisuru::Util.present?(time)

          if Kanrisuru::Util.present?(no_wall)
            command.append_flag('--no-wall')
          else
            command << time if time
            command << message if message
          end
        end

        begin
          execute_shell(command)
          Kanrisuru::Result.new(command)
        rescue IOError
          ## When rebooting 'now', ssh io stream closes
          ## Set exit status to 0
          command.handle_status(0)
          Kanrisuru::Result.new(command)
        end
      end

      def poweroff(opts = {})
        time = opts[:time]
        cancel = opts[:cancel]
        message = opts[:message]
        no_wall = opts[:no_wall]

        command = Kanrisuru::Command.new('shutdown')

        if Kanrisuru::Util.present?(cancel)
          command.append_flag('-c')
          command << message if message
        else
          time = format_shutdown_time(time) if Kanrisuru::Util.present?(time)

          if Kanrisuru::Util.present?(no_wall)
            command.append_flag('--no-wall')
          else
            command << time if time
            command << message if message
          end
        end

        begin
          execute_shell(command)

          Kanrisuru::Result.new(command)
        rescue IOError
          ## When powering off 'now', ssh io stream closes
          ## Set exit status to 0
          command.handle_status(0)

          Kanrisuru::Result.new(command)
        end
      end

      private

      def parse_policy_abbr(value)
        case value
        when '-'
          'not reported'
        when 'TS'
          'SCHED_OTHER'
        when 'FF'
          'SCHED_FIFO'
        when 'RR'
          'SCHED_RR'
        when 'B'
          'SCHED_BATCH'
        when 'ISO'
          'SCHED_ISO'
        when 'IDL'
          'SCHED_IDLE'
        when 'DLN'
          'SCHED_DEADLINE'
        else
          'unknown value'
        end
      end

      def build_process_list(rows)
        rows.map do |row|
          values = *row.split(/\s+/, 15)
          values.shift if values[0] == ''

          ProcessInfo.new(
            values[0].to_i,
            values[1],
            values[2].to_i,
            values[3],
            values[4].to_i,
            values[5].to_i,
            values[6].to_f,
            values[7].to_f,
            values[8],
            values[9].to_i,
            values[10].to_i,
            values[11],
            parse_policy_abbr(values[11]),
            values[12],
            values[13]
          )
        end
      end

      def format_shutdown_time(time)
        if time.instance_of?(Integer) || !/^[0-9]+$/.match(time).nil?
          "+#{time}"
        elsif !/^[0-9]{0,2}:[0-9]{0,2}$/.match(time).nil? || time == 'now'
          time
        else
          raise ArgumentError, 'Invalid time format'
        end
      end
    end
  end
end
