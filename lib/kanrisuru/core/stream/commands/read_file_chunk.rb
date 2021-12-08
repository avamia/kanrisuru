module Kanrisuru
  module Core
    module Stream
      def read_file_chunk(path, start_line, end_line)
        if !start_line.instance_of?(Integer) || !end_line.instance_of?(Integer) ||
           start_line > end_line || start_line.negative? || end_line.negative?
          raise ArgumentError, 'Invalid start or end'
        end

        end_line = end_line - start_line + 1
        command = Kanrisuru::Command.new("tail -n +#{start_line} #{path} | head -n #{end_line}")

        execute_shell(command)

        Kanrisuru::Result.new(command, &:to_a)
      end
    end
  end
end
