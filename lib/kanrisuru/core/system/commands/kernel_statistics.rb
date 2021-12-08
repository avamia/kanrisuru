module Kanrisuru
  module Core
    module System
      def kstat
        kernel_statistics
      end
      
      def kernel_statistics
        command = Kanrisuru::Command.new('cat /proc/stat')

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::KernelStatistics.parse(cmd)
        end
      end
    end
  end
end
