# frozen_string_literal: true

module Kanrisuru
  module Core
    module File
      def touch(paths, opts = {})
        date = opts[:date]

        paths = [paths] if paths.instance_of?(String)
        command = Kanrisuru::Command.new('touch')
        command.append_array(paths)

        command.append_flag('-a', opts[:atime])
        command.append_flag('-m', opts[:mtime])
        command.append_flag('-c', opts[:nofiles])

        if Kanrisuru::Util.present?(date)
          date = Date.parse(date) if date.instance_of?(String)
          command.append_arg('-d', date)
        end

        command.append_arg('-r', opts[:reference])

        execute_shell(command)

        Kanrisuru::Result.new(command) do
          paths.map do |path|
            stat(path).data
          end
        end
      end
    end
  end
end
