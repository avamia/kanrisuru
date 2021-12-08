# frozen_string_literal: true

module Kanrisuru
  module Core
    module IP
      module Parser
        class Maddress < Base
          class << self
            def parse(command, action, version)
              return unless %w[show list].include?(action)

              if version >= Kanrisuru::Core::IP::IPROUTE2_JSON_VERSION
                begin
                  ip_maddress_result_json(command.to_json)
                rescue JSON::ParserError
                  ip_maddress_result_parse(command.to_a)
                end
              else
                ip_maddress_result_parse(command.to_a)
              end
            end

            def ip_maddress_result_json(rows)
              rows.map do |row|
                maddress = Kanrisuru::Core::IP::IPMAddress.new(row['ifindex'], row['ifname'], [])

                entries = row['maddr'] || []
                entries.each do |entry|
                  ipmaddress_entry = Kanrisuru::Core::IP::IPMAddressEntry.new
                  entry.each do |key, value|
                    ipmaddress_entry[key] = value
                  end

                  maddress.maddr << ipmaddress_entry
                end

                maddress
              end
            end

            def ip_maddress_result_parse(lines)
              rows = []
              current_row = nil

              lines.each.with_index do |line, _index|
                case line
                when /^\d+:\s/
                  rows << current_row unless current_row.nil?

                  current_row = Kanrisuru::Core::IP::IPMAddress.new
                  parse_ip_maddr_name(current_row, line)
                when /^link/
                  _, link = line.split

                  entry = Kanrisuru::Core::IP::IPMAddressEntry.new
                  entry.link = link

                  current_row.maddr << entry
                when /^inet/
                  values = line.split

                  entry = Kanrisuru::Core::IP::IPMAddressEntry.new
                  values.each.with_index do |value, index|
                    case value
                    when 'inet', 'inet6'
                      entry.family = value
                      entry.address = values[index + 1]
                    when 'users'
                      entry.users = values[index + 1].to_i
                    end
                  end

                  current_row.maddr << entry
                end
              end

              rows << current_row
              rows
            end
          end
        end
      end
    end
  end
end
