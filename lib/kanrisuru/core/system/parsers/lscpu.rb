module Kanrisuru::Core::System
  module Parser
    class Lcspu 
      def self.parse(command)
        lines = command.to_a

        result = Kanrisuru::Core::System::CPUArchitecture.new
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
            result.vulnerabilities << Kanrisuru::Core::System::CPUArchitectureVulnerability.new(name, data)
          when 'Flags'
            result.flags = data.split
          end
        end

        result
      end
    end
  end
end