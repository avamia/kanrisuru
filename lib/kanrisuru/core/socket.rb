# frozen_string_literal: true

require 'ipaddr'

module Kanrisuru
  module Core
    module Socket
      extend OsPackage::Define

      os_define :linux, :ss

      Statistics = Struct.new(
        :netid, :state, :receive_queue, :send_queue,
        :local_address, :local_port, :peer_address, :peer_port,
        :memory
      )

      StatisticsMemory = Struct.new(
        :rmem_alloc, :rcv_buf, :wmem_alloc, :snd_buf,
        :fwd_alloc, :wmem_queued, :ropt_mem, :back_log, :sock_drop
      )

      TCP_STATES = %w[
        established syn-sent syn-recv
        fin-wait-1 fin-wait-2 time-wait
        closed close-wait last-ack listening closing
      ].freeze

      OTHER_STATES = %w[
        all connected synchronized bucket syn-recv
        big
      ].freeze

      TCP_STATE_ABBR = {
        'ESTAB' => 'established', 'LISTEN' => 'listening', 'UNCONN' => 'unconnected',
        'SYN-SENT' => 'syn-sent', 'SYN-RECV' => 'syn-recv', 'FIN-WAIT-1' => 'fin-wait-1',
        'FIN-WAIT-2' => 'fin-wait-2', 'TIME-WAIT' => 'time-wait', 'CLOSE-WAIT' => 'close-wait',
        'LAST-ACK' => 'last-ack', 'CLOSING' => 'closing'
      }.freeze

      def ss(opts = {})
        state = opts[:state]
        expression = opts[:expression]

        command = Kanrisuru::Command.new('ss')

        command.append_flag('-a')
        command.append_flag('-m')

        command.append_flag('-n', opts[:numeric])
        command.append_flag('-t', opts[:tcp])
        command.append_flag('-u', opts[:udp])
        command.append_flag('-x', opts[:unix])
        command.append_flag('-w', opts[:raw])

        command.append_arg('-f', opts[:family])

        if Kanrisuru::Util.present?(state)
          raise ArgumentError, 'invalid filter state' if !TCP_STATES.include?(state) && !OTHER_STATES.include?(state)

          command.append_arg('state', state)
        end

        command << expression if Kanrisuru::Util.present?(expression)

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          rows = []

          ## New lines with tabs are from text overflow
          ## on on stdout of SS command.
          ## Replace the newline and tab chars with a space.
          string = cmd.raw_result.join
          string = string.gsub("\n\t", "\s")
          lines = string.lines.map(&:strip)

          headers = lines.shift

          lines.each do |line|
            values = line.split
            next if values.length < 5

            socket_stats = Statistics.new
            socket_stats.netid =
              if headers.include?('Netid')
                values.shift
              elsif opts[:tcp]
                'tcp'
              elsif opts[:udp]
                'udp'
              elsif opts[:raw]
                'raw'
              else
                ''
              end

            socket_stats.state = if headers.include?('State')
                                   TCP_STATE_ABBR[values.shift]
                                 else
                                   state
                                 end

            socket_stats.receive_queue = values.shift.to_i
            socket_stats.send_queue = values.shift.to_i

            address, port = parse_address_port(values)
            socket_stats.local_address = address
            socket_stats.local_port = port

            address, port = parse_address_port(values)
            socket_stats.peer_address = address
            socket_stats.peer_port = port

            socket_stats.memory = parse_memory(values.shift)

            rows << socket_stats
          end

          rows
        end
      end

      private

      def parse_memory(string)
        return if Kanrisuru::Util.blank?(string) ||
                  Regexp.new(/skmem:\((\S+)\)/).match(string).nil?

        _, string = string.split(/skmem:\((\S+)\)/)
        values = string.split(',')

        memory = StatisticsMemory.new
        memory.rmem_alloc  = values[0].split(/(\d+)/)[1].to_i
        memory.rcv_buf     = values[1].split(/(\d+)/)[1].to_i
        memory.wmem_alloc  = values[2].split(/(\d+)/)[1].to_i
        memory.snd_buf     = values[3].split(/(\d+)/)[1].to_i
        memory.fwd_alloc   = values[4].split(/(\d+)/)[1].to_i
        memory.wmem_queued = values[5].split(/(\d+)/)[1].to_i
        memory.ropt_mem    = values[6].split(/(\d+)/)[1].to_i
        memory.back_log    = values[7].split(/(\d+)/)[1].to_i
        memory.sock_drop   = values[8].split(/(\d+)/)[1].to_i

        memory
      end

      def parse_address_port(values)
        address = values.shift
        port = nil

        if address == '*' && Regexp.new(/skmem:\((\S+)\)/).match(values[0])
          port = '*'
        elsif Regexp.new(/\[(\S+)\]/).match(address)
          tokens = address.split(/\[(\S+)\]/)
          address = "[#{tokens[1]}]"
          _, port = tokens[2].split(/:(\S+)/)
        elsif Regexp.new(/:\S+/).match(address)
          address, port = address.split(/:(\S+)/)
        else
          port = values.shift
        end

        port = Kanrisuru::Util.numeric?(port) ? port.to_i : port
        [address, port]
      end
    end
  end
end
