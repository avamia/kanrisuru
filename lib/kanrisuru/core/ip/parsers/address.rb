# frozen_string_literal: true

module Kanrisuru
  module Core
    module IP
      module Parser
        class Address < Base
          class << self
            def parse(command, action, version)
              return unless %w[show list].include?(action)

              if version >= Kanrisuru::Core::IP::IPROUTE2_JSON_VERSION
                begin
                  ip_address_result_json(command.to_json)
                rescue JSON::ParserError
                  ip_address_result_parse(command.to_a)
                end
              else
                ip_address_result_parse(command.to_a)
              end
            end

            def ip_address_result_parse(lines)
              rows = []
              current_row = nil

              lines.each.with_index do |line, index|
                case line
                when /^\d+:\s/
                  rows << current_row unless current_row.nil?

                  current_row = Kanrisuru::Core::IP::IPAddressProperty.new
                  current_row.address_info = []

                  parse_ip_row(current_row, line)
                when /^link/
                  parse_link(current_row, line)
                when /^inet/
                  parse_address_info(current_row, line)
                when /^valid_lft/
                  parse_valid(current_row, line)
                when /^RX:/
                  parse_rx(current_row, lines[index + 1])
                when /^TX:/
                  parse_tx(current_row, lines[index + 1])
                end
              end

              rows << current_row
              rows
            end

            def ip_address_result_json(rows)
              result = []
              rows.each do |row|
                next if row['ifindex'].instance_of?(NilClass)

                new_row = Kanrisuru::Core::IP::IPAddressProperty.new(
                  row['ifindex'], row['ifname'], row['flags'], row['mtu'], row['qdisc'],
                  row['operstate'], row['group'], row['txqlen'], row['link_type'], row['address'], []
                )

                if row.key?('stats64')
                  rx = row['stats64']['rx']
                  tx = row['stats64']['tx']

                  new_row[:stats] = Kanrisuru::Core::IP::IPStats.new(
                    Kanrisuru::Core::IP::IPStatRX.new(
                      rx['bytes'], rx['packets'], rx['errors'],
                      rx['dropped'], rx['over_errors'], rx['multicast']
                    ),
                    Kanrisuru::Core::IP::IPStatTX.new(
                      tx['bytes'], tx['packets'], tx['errors'],
                      tx['dropped'], tx['carrier_errors'], tx['collisions']
                    )
                  )
                end

                addr_info = row['addr_info'] || []

                new_row[:address_info] = addr_info.map do |address|
                  dynamic = address['dynamic'] == true || address['dynamic'] == 'true'

                  Kanrisuru::Core::IP::IPAddressInfo.new(
                    address['family'],
                    IPAddr.new(address['local']),
                    address['broadcast'],
                    address['scope'],
                    dynamic,
                    address['valid_life_time'], address['preferred_life_time']
                  )
                end

                result << new_row
              end

              result
            end
          end
        end
      end
    end
  end
end
