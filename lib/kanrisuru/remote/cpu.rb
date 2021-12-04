# frozen_string_literal: true

module Kanrisuru
  module Remote
    class Cpu
      def initialize(host)
        @host = host

        raise 'Not implemented' unless @host.os && @host.os.kernel == 'Linux'

        initialize_linux
      end

      def load_average
        @host.load_average.to_a
      end

      def load_average1
        load_average[0]
      end

      def load_average5
        load_average[1]
      end

      def load_average15
        load_average[2]
      end

      def architecture
        @cpu_architecture.architecture
      end

      def sockets
        @cpu_architecture.sockets
      end

      def cores
        @cpu_architecture.cores
      end

      def total
        @cpu_architecture.cores
      end

      def count
        @cpu_architecture.cores
      end

      def threads_per_core
        @cpu_architecture.threads_per_core
      end

      def cores_per_socket
        @cpu_architecture.cores_per_socket
      end

      def numa_nodes
        @cpu_architecture.numa_nodes
      end

      def vendor_id
        @cpu_architecture.vendor_id
      end

      def cpu_family
        @cpu_architecture.cpu_family
      end

      def model
        @cpu_architecture.model
      end

      def model_name
        @cpu_architecture.model_name
      end

      def byte_order
        @cpu_architecture.byte_order
      end

      def address_sizes
        @cpu_architecture.address_sizes
      end

      def cpu_mhz
        @cpu_architecture.cpu_mhz
      end

      def cpu_max_mhz
        @cpu_architecture.cpu_max_mhz
      end

      def cpu_min_mhz
        @cpu_architecture.cpu_min_mhz
      end

      def hypervisor
        @cpu_architecture.hypervisor_vendor
      end

      def virtualization_type
        @cpu_architecture.virtualization_type
      end

      def flags
        @cpu_architecture.flags
      end

      def hyperthreading?
        threads_per_core > 1
      end

      private

      def initialize_linux
        @cpu_architecture = @host.lscpu.data
      end
    end
  end
end
