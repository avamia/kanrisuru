# frozen_string_literal: true

require 'date'

module Kanrisuru
  module Core
    module System
      extend OsPackage::Define

      os_define :linux, :load_env
      os_define :linux, :cpu_info
      os_define :linux, :load_average
      os_define :linux, :free
      os_define :linux, :ps
      os_define :linux, :kill

      os_define :linux, :uptime

      os_define :linux, :w
      os_define :linux, :who

      os_define :linux, :reboot
      os_define :linux, :poweroff

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
