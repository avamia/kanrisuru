module Kanrisuru::Core::IP
  module Parser
    class Neighbour < Base
      class << self
        def parse(command, action, version)
          return unless %w[show list].include?(action)

          if version >= Kanrisuru::Core::IP::IPROUTE2_JSON_VERSION
            begin
              ip_neighbour_result_json(command.to_json)
            rescue JSON::ParserError
              ip_neighbour_result_parse(command.to_a)
            end
          else
            ip_neighbour_result_parse(command.to_a)
          end
        end

        def ip_neighbour_result_json(rows)
          rows.map do |row|
            neighbour = Kanrisuru::Core::IP::IPNeighbour.new(
              IPAddr.new(row['dst']),
              row['dev'],
              row['lladdr'],
              row['state']
            )

            if row.key?('used') || row.key?('confirmed') ||
               row.key?('refcnt') || row.key?('updated') ||
               row.key?('probes')
              neighbour.stats = Kanrisuru::Core::IP::IPNeighbourStats.new

              neighbour.stats.ref_count = row['refcnt']
              neighbour.stats.used = row['used']
              neighbour.stats.confirmed = row['confirmed']
              neighbour.stats.probes = row['probes']
              neighbour.stats.updated = row['updated']
            end

            neighbour
          end
        end

        def ip_neighbour_result_parse(lines)
          rows = []
          lines.each do |line|
            values = line.split

            neighbour = Kanrisuru::Core::IP::IPNeighbour.new(IPAddr.new(values[0]))
            neighbour.state = [values[values.length - 1]]

            if line.include?('probes') || line.include?('used') || line.include?('ref')
              neighbour.stats = Kanrisuru::Core::IP::IPNeighbourStats.new
            end

            values.each.with_index do |value, index|
              case value
              when 'dev'
                neighbour.device = values[index + 1]
              when 'lladdr'
                neighbour.lladdr = values[index + 1]
              when 'ref'
                neighbour.stats.ref_count = values[index + 1] ? values[index + 1].to_i : nil
              when 'used'
                used, confirmed, updated = values[index + 1].split('/')

                neighbour.stats.used = used ? used.to_i : nil
                neighbour.stats.updated = updated ? updated.to_i : nil
                neighbour.stats.confirmed = confirmed ? confirmed.to_i : nil
              when 'probes'
                neighbour.stats.probes = values[index + 1] ? values[index + 1].to_i : nil
              end
            end

            rows << neighbour
          end

          rows
        end
      end
    end
  end
end
