module Kanrisuru::Core::System
  module Parser
    class Lsof
      class << self
        def parse(command)
          lines = cmd.to_a

          current_row = nil
          current_pid = nil
          current_user = nil
          current_command = nil

          rows = []

          lines.each do |line|
            case line
            when /^p/
              current_pid = parse_lsof(line, 'p').to_i
            when /^c/
              current_command = parse_lsof(line, 'c')
            when /^u/
              current_user = parse_lsof(line, 'u').to_i
            when /^f/
              rows << current_row if current_row

              current_row = OpenFile.new
              current_row.pid = current_pid
              current_row.command = current_command
              current_row.uid = current_user

              current_row.file_descriptor = parse_lsof(line, 'f')
            when /^t/
              current_row.type = parse_lsof(line, 't')
            when /^D/
              current_row.device = parse_lsof(line, 'D')
            when /^s/
              current_row.fsize = parse_lsof(line, 's').to_i
            when /^i/
              current_row.inode = parse_lsof(line, 'i').to_i
            when /^n/
              current_row.name = parse_lsof(line, 'n')
            end
          end

          rows << current_row if current_row

          rows
        end

        def parse_lsof(line, char)
          line.split(char, 2)[1]
        end
      end
    end
  end
end