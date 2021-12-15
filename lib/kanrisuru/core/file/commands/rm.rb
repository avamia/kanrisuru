# frozen_string_literal: true

module Kanrisuru
  module Core
    module File
      def rm(paths, opts = {})
        paths = [paths] if paths.instance_of?(String)

        paths.each do |path|
          raise ArgumentError, "Can't delete root path" if path == '/' || realpath(path).path == '/'
        end

        command = Kanrisuru::Command.new('rm')
        command.append_array(paths)

        command.append_flag('--preserve-root')
        command.append_flag('-f', opts[:force])
        command.append_flag('-r', opts[:recursive])

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end

      def rmdir(paths, opts = {})
        paths = [paths] if paths.instance_of?(String)
        paths.each do |path|
          raise ArgumentError, "Can't delete root path" if path == '/' || realpath(path).path == '/'
        end

        command = Kanrisuru::Command.new("rmdir #{paths.join(' ')}")
        command.append_flag('--ignore-fail-on-non-empty', opts[:silent])
        command.append_flag('--parents', opts[:parents])

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
