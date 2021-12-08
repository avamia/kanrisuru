# frozen_string_literal: true

module Kanrisuru
  module Core
    module IP
      module Parser
        class Base
          class << self
            def ip_address_label_result_json(rows)
              result = []

              rows.each do |row|
                new_row = Kanrisuru::Core::IP::IPAddressLabel.new(
                  row['address'], row['prefixlen'], row['label']
                )

                result << new_row
              end

              result
            end

            def ip_address_label_result_parse(lines)
              lines.map do |line|
                _, addr, _, label = line.split(/\s/)
                address, prefix_length = addr.split(%r{/})

                Kanrisuru::Core::IP::IPAddressLabel.new(address, prefix_length.to_i, label)
              end
            end

            def parse_alias(row, line)
              _, alias_string = line.split('alias')
              row.alias = alias_string
            end

            def parse_ip_maddr_name(row, line)
              index = line.match(/^\d+/).to_s.to_i
              _, name = line.split(/^\d+:\s/)

              row.index = index
              row.name = name
              row.maddr = []
            end

            def parse_ip_row(row, line)
              index = line.match(/^\d+/).to_s.to_i
              _, string = line.split(/^\d+:\s/)
              name = string.match(/^\w+/).to_s
              _, string = string.split(/^\w+:\s/)
              _, flags, string = string.split(/(<.+>)\s/)

              flags = flags.gsub(/<?>?/, '')
              flags = flags.split(',')

              row.index = index
              row.name = name
              row.flags = flags

              values = string.split(/\s/)
              values.each.with_index do |_, i|
                case values[i]
                when 'mtu'
                  row.mtu = values[i + 1].to_i
                when 'qdisc'
                  row.qdisc = values[i + 1]
                when 'state'
                  row.state = values[i + 1]
                when 'group'
                  row.group = values[i + 1]
                when 'qlen'
                  row.qlen = values[i + 1].to_i
                when 'mode'
                  row.link_mode = values[i + 1]
                end
              end
            end

            def parse_link(row, line)
              _, string = line.split(%r{^link/})
              link_type, mac_address = string.split

              row.link_type = link_type
              row.mac_address = mac_address
            end

            def parse_address_info(row, line)
              values = line.split
              address_info = Kanrisuru::Core::IP::IPAddressInfo.new

              values.each.with_index do |_, index|
                case values[index]
                when 'inet', 'inet6'
                  address_info.family = values[index]
                  address_info.ip = IPAddr.new(values[index + 1].split('/')[0])
                when 'brd'
                  address_info.broadcast = values[index + 1]
                when 'scope'
                  address_info.scope = values[index + 1]
                when 'dynamic'
                  address_info.dynamic = true
                end
              end

              row.address_info << address_info
            end

            def parse_valid(row, line)
              values = line.split

              values.each.with_index do |_, index|
                case values[index]
                when 'valid_lft'
                  row.address_info.last.valid_life_time = values[index + 1]
                when 'preferred_lft'
                  row.address_info.last.preferred_life_time = values[index + 1]
                end
              end
            end

            def parse_rx(row, line)
              values = line.split

              bytes = values[0].to_i
              packets = values[1].to_i
              errors = values[2].to_i
              dropped = values[3].to_i
              over_errors = values[4].to_i
              multicast = values[5].to_i

              row.stats = Kanrisuru::Core::IP::IPStats.new
              row.stats.rx = Kanrisuru::Core::IP::IPStatRX.new(
                bytes,
                packets,
                errors,
                dropped,
                over_errors,
                multicast
              )
            end

            def parse_tx(row, line)
              values = line.split

              bytes = values[0].to_i
              packets = values[1].to_i
              errors = values[2].to_i
              dropped = values[3].to_i
              carrier_errors = values[4].to_i
              collisions = values[5].to_i

              row.stats.tx = Kanrisuru::Core::IP::IPStatTX.new(
                bytes,
                packets,
                errors,
                dropped,
                carrier_errors,
                collisions
              )
            end
          end
        end
      end
    end
  end
end
