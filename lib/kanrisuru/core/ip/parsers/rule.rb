# frozen_string_literal: true

module Kanrisuru
  module Core
    module IP
      module Parser
        class Rule < Base
          class << self
            def parse(command, action, version)
              return unless %w[show list].include?(action)

              if version >= Kanrisuru::Core::IP::IPROUTE2_JSON_VERSION
                begin
                  ip_rule_result_json(command.to_json)
                rescue JSON::ParserError
                  ip_rule_result_parse(command.to_a)
                end
              else
                ip_rule_result_parse(command.to_a)
              end
            end

            def ip_rule_result_json(rows)
              rows.map do |row|
                Kanrisuru::Core::IP::IPRule.new(
                  row['priority'],
                  row['src'],
                  row['table']
                )
              end
            end

            def ip_rule_result_parse(lines)
              rows = []
              lines.each do |line|
                _, priority, string = line.split(/(\d+):\s/)
                values = string.split(/\s/)

                rule = Kanrisuru::Core::IP::IPRule.new(priority)

                values.each.with_index do |value, index|
                  case value
                  when 'from'
                    rule.source = values[index + 1]
                  when 'lookup'
                    rule.table = values[index + 1]
                  end
                end

                rows << rule
              end

              rows
            end
          end
        end
      end
    end
  end
end
