# frozen_string_literal: true

module Kanrisuru
  module Core
    module Socket
      module Parser
        class Ss
          class << self
            def parse(command, state, opts)
              rows = []

              ## New lines with tabs are from text overflow
              ## on on stdout of SS command.
              ## Replace the newline and tab chars with a space.
              string = command.raw_result.join
              string = string.gsub("\n\t", "\s")
              lines = string.lines.map(&:strip)

              headers = lines.shift

              lines.each do |line|
                values = line.split
                next if values.length < 5

                socket_stats = Kanrisuru::Core::Socket::Statistics.new
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
                                       Kanrisuru::Core::Socket::TCP_STATE_ABBR[values.shift]
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

            def parse_memory(string)
              return if Kanrisuru::Util.blank?(string) ||
                        Regexp.new(/skmem:\((\S+)\)/).match(string).nil?

              _, string = string.split(/skmem:\((\S+)\)/)
              values = string.split(',')

              memory = Kanrisuru::Core::Socket::StatisticsMemory.new
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
    end
  end
end
