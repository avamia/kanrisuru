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

      def sockets
        @sockets_count
      end

      def cores
        @logical_cores_count
      end

      def total
        @logical_cores_count
      end

      def count
        @logical_cores_count
      end

      def threads_per_core
        @threads_per_core_count
      end

      def cores_per_socket
        @cores_per_socket_count
      end

      def hyperthreading?
        threads_per_core > 1
      end

      private

      def initialize_linux
        @sockets_count          = @host.cpu_info('sockets').to_i
        @cores_per_socket_count = @host.cpu_info('cores_per_socket').to_i
        @threads_per_core_count = @host.cpu_info('threads').to_i
        @logical_cores_count    = @host.cpu_info('cores').to_i
      end
    end
  end
end
