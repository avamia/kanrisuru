module Kanrisuru
  module Core
    module System
      def free(type)
        conversions = {
          total: 'MemTotal',
          free: 'MemFree',
          swap: 'SwapTotal',
          swap_free: 'SwapFree'
        }

        option = conversions[type.to_sym]
        raise ArgumentError, 'Invalid mem type' unless option

        command = Kanrisuru::Command.new("cat /proc/meminfo | grep -i '^#{option}' | awk '{print $2}'")
        execute(command)

        ## In kB
        Kanrisuru::Result.new(command, &:to_i)
      end
    end
  end
end
