# frozen_string_literal: true

module Kanrisuru
  module Core
    module File
      def chmod(path, mode, opts = {})
        recursive = opts[:recursive]

        command =
          if mode.instance_of?(String) && (mode.include?(',') || /[=+-]/.match(mode))
            Kanrisuru::Command.new("chmod #{mode} #{path}")
          elsif mode.instance_of?(Kanrisuru::Mode)
            Kanrisuru::Command.new("chmod #{mode.numeric} #{path}")
          else
            mode = Kanrisuru::Mode.new(mode)
            Kanrisuru::Command.new("chmod #{mode.numeric} #{path}")
          end

        command.append_flag('-R', recursive)

        execute_shell(command)

        Kanrisuru::Result.new(command) do
          stat(path).data
        end
      end
    end
  end
end
