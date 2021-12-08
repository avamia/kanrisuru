module Kanrisuru::Core::System
  module Parser
    class Ps 
      class << self
        def parse(command)
          ## Have found issues with regular newline parsing from command
          ## most likely a buffer overflow from SSH buffer.
          ## Join string then split by newline.
          result_string = command.raw_result.join
          rows = result_string.split("\n")
          
          build_process_list(rows) 
        end

        def build_process_list(rows)
          rows.map do |row|
            values = *row.split(/\s+/, 15)
            values.shift if values[0] == ''

            Kanrisuru::Core::Syste::ProcessInfo.new(
              values[0].to_i,
              values[1],
              values[2].to_i,
              values[3],
              values[4].to_i,
              values[5].to_i,
              values[6].to_f,
              values[7].to_f,
              values[8],
              values[9].to_i,
              values[10].to_i,
              values[11],
              parse_policy_abbr(values[11]),
              values[12],
              values[13]
            )
          end
        end

        def parse_policy_abbr(value)
          case value
          when '-'
            'not reported'
          when 'TS'
            'SCHED_OTHER'
          when 'FF'
            'SCHED_FIFO'
          when 'RR'
            'SCHED_RR'
          when 'B'
            'SCHED_BATCH'
          when 'ISO'
            'SCHED_ISO'
          when 'IDL'
            'SCHED_IDLE'
          when 'DLN'
            'SCHED_DEADLINE'
          else
            'unknown value'
          end
        end
      end
    end
  end
end