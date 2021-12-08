module Kanrisuru::Core::System
  module Parser
    class KernelStatistics
      def self.parse(command)
        lines = cmd.to_a

        result = Kanrisuru::Core::System::KernelStatistic.new
        result.cpus = []

        lines.each do |line|
          values = line.split
          field = values[0]
          values = values[1..-1].map(&:to_i)

          case field
          when /^cpu/
            cpu_stat = Kanrisuru::Core::System::KernelStatisticCpu.new
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
  end
end
