# frozen_string_literal: true

module Kanrisuru
  module Core
    module System
      def history(opts = {})
        histfile = opts[:histfile] || '~/.bash_history'

        command = Kanrisuru::Command.new("HISTFILE=#{histfile}; history -r; history")

        if Kanrisuru::Util.present?(opts[:delete])
          command.append_arg('-d', Kanrisuru::Util.array_join_string(opts[:delete], ' '))
        elsif Kanrisuru::Util.present?(opts[:clear])
          command.append_flag('-c')
        elsif Kanrisuru::Util.present?(opts[:n])
          command << opts[:n]
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          return if Kanrisuru::Util.present?(opts[:delete]) || Kanrisuru::Util.present?(opts[:clear])

          Parser::History.parse(cmd)
        end
      end
    end
  end
end
