# frozen_string_literal: true

module Kanrisuru
  module Core
    module Socket
      def ss(opts = {})
        state = opts[:state]
        expression = opts[:expression]
        family = opts[:family]

        command = Kanrisuru::Command.new('ss')

        command.append_flag('-a')
        command.append_flag('-m')

        command.append_flag('-n', opts[:numeric])
        command.append_flag('-t', opts[:tcp])
        command.append_flag('-u', opts[:udp])
        command.append_flag('-x', opts[:unix])
        command.append_flag('-w', opts[:raw])

        if Kanrisuru::Util.present?(family)
          raise ArgumentError, 'invalid family type' unless NETWORK_FAMILIES.include?(family)

          command.append_arg('-f', family)
        end

        if Kanrisuru::Util.present?(state)
          raise ArgumentError, 'invalid filter state' if !TCP_STATES.include?(state) && !OTHER_STATES.include?(state)

          command.append_arg('state', state)
        end

        command << expression if Kanrisuru::Util.present?(expression)

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Ss.parse(cmd, state)
        end
      end
    end
  end
end
