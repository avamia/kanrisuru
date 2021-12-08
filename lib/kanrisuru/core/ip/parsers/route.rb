module Kanrisuru::Core::IP
  module Parser
    class Route < Base
      class << self 
        def parse(command, action, version)
          return unless %w[show list].include?(action)

          if version >= Kanrisuru::Core::IP::IPROUTE2_JSON_VERSION
            begin
              ip_route_result_json(command.to_json)
            rescue JSON::ParserError
              ip_route_result_parse(command.to_a)
            end
          else
            ip_route_result_parse(command.to_a)
          end
        end 

        def ip_route_result_json(rows)
          rows.map do |row|
            Kanrisuru::Core::IP::IPRoute.new(
              row['dst'],
              row['gateway'],
              row['dev'],
              row['protocol'],
              row['scope'],
              row['prefsrc'],
              row['metric'],
              row['flags']
            )
          end
        end

        def ip_route_result_parse(lines)
          rows = []

          lines.map do |line|
            values = line.split(/\s/)

            ip_route = Kanrisuru::Core::IP::IPRoute.new(values[0])
            ip_route.flags = []

            values.each.with_index do |value, index|
              case value
              when 'via'
                ip_route.gateway = values[index + 1]
              when 'dev'
                ip_route.device = values[index + 1]
              when 'proto'
                ip_route.protocol = values[index + 1]
              when 'src'
                ip_route.preferred_source = values[index + 1]
              when 'scope'
                ip_route.scope = values[index + 1]
              when 'flags'
                ip_route.flags = values[index + 1]
              when 'metric'
                ip_route.metric = values[index + 1]
              end
            end

            rows << ip_route
          end

          rows
        end
      end
    end
  end
end
 