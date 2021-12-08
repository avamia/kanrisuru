module Kanrisuru
  module Core
    module System
      def kill(signal, pids)
        raise ArgumentError, 'Invalid signal' unless Kanrisuru::Util::Signal.valid?(signal)

        ## Use named signals for readabilitiy
        signal = Kanrisuru::Util::Signal[signal] if signal.instance_of?(Integer)

        command = Kanrisuru::Command.new('kill')
        command << "-#{signal}"
        command << (pids.instance_of?(Array) ? pids.join(' ') : pids)

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
