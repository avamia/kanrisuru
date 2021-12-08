# frozen_string_literal: true

module Kanrisuru
  module Core
    module File
      def link(src, dest, opts = {})
        ln(src, dest, opts)
      end

      def ln(src, dest, opts = {})
        ## Can't hardlink dirs
        return false if dir?(src)

        command = Kanrisuru::Command.new("ln #{src} #{dest}")
        command.append_flag('-f', opts[:force])

        execute_shell(command)

        Kanrisuru::Result.new(command) do
          stat(dest).data
        end
      end
    end
  end
end
