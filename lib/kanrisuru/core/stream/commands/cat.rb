# frozen_string_literal: true

module Kanrisuru
  module Core
    module Stream
      def cat(files, opts = {})
        command = Kanrisuru::Command.new('cat')
        command.append_flag('-T', opts[:show_tabs])
        command.append_flag('-n', opts[:number])
        command.append_flag('-s', opts[:squeeze_blank])
        command.append_flag('-v', opts[:show_nonprinting])
        command.append_flag('-E', opts[:show_ends])
        command.append_flag('-b', opts[:number_nonblank])
        command.append_flag('-A', opts[:show_all])

        command.append_array(files)

        append_file(command, opts)
        execute_shell(command)

        Kanrisuru::Result.new(command, &:to_a)
      end
    end
  end
end
