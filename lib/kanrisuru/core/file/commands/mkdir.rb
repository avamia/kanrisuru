# frozen_string_literal: true

module Kanrisuru
  module Core
    module File
      def mkdir(path, opts = {})
        owner     = opts[:owner]
        group     = opts[:group]
        recursive = opts[:recursive]

        command = Kanrisuru::Command.new("mkdir #{path}")
        command.append_flag('-p', opts[:silent])

        if Kanrisuru::Util.present?(opts[:mode])
          mode = opts[:mode]
          if mode.instance_of?(Kanrisuru::Mode)
            mode = mode.numeric
          elsif mode.instance_of?(String) && (mode.include?(',') || /[=+-]/.match(mode))
            mode = Kanrisuru::Mode.new(mode).numeric
          end

          command.append_arg('-m', mode)
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do
          if Kanrisuru::Util.present?(owner) || Kanrisuru::Util.present?(group)
            chown(path, owner: owner, group: group, recursive: recursive)
          end

          stat(path).data
        end
      end
    end
  end
end
