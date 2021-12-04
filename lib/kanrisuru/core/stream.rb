# frozen_string_literal: true

module Kanrisuru
  module Core
    module Stream
      extend OsPackage::Define

      os_define :linux, :head
      os_define :linux, :tail
      os_define :linux, :read_file_chunk
      os_define :linux, :sed
      os_define :linux, :echo
      os_define :linux, :cat

      def head(path, opts = {})
        command = Kanrisuru::Command.new('head')
        command.append_arg('-c', opts[:bytes])
        command.append_arg('-n', opts[:lines])
        command << path

        execute_shell(command)

        Kanrisuru::Result.new(command, &:to_a)
      end

      def tail(path, opts = {})
        command = Kanrisuru::Command.new('tail')
        command.append_arg('-c', opts[:bytes])
        command.append_arg('-n', opts[:lines])
        command << path

        execute_shell(command)

        Kanrisuru::Result.new(command, &:to_a)
      end

      def read_file_chunk(path, start_line, end_line)
        if !start_line.instance_of?(Integer) || !end_line.instance_of?(Integer) ||
           start_line > end_line || start_line.negative? || end_line.negative?
          raise ArgumentError, 'Invalid start or end'
        end

        end_line = end_line - start_line + 1
        command = Kanrisuru::Command.new("tail -n +#{start_line} #{path} | head -n #{end_line}")

        execute_shell(command)

        Kanrisuru::Result.new(command, &:to_a)
      end

      def sed(path, expression, replacement, opts = {})
        command = Kanrisuru::Command.new('sed')
        command.append_flag('-i', opts[:in_place])
        command.append_flag('-r', opts[:regexp_extended])

        command << "'s/#{expression}/#{replacement}/g'"
        command << "'#{path}'"

        append_file(command, opts)
        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          if Kanrisuru::Util.present?(opts[:new_file])
            nil
          else
            cmd.to_a.join("\n")
          end
        end
      end

      def echo(text, opts = {})
        command = Kanrisuru::Command.new('echo')
        command.append_flag('-e', opts[:backslash])
        command << "'#{text}'"

        append_file(command, opts)
        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          if Kanrisuru::Util.present?(opts[:new_file])
            nil
          else
            cmd.to_s
          end
        end
      end

      def cat(files, opts = {})
        command = Kanrisuru::Command.new('cat')
        command.append_flag('-T', opts[:show_tabs])
        command.append_flag('-n', opts[:number])
        command.append_flag('-s', opts[:squeeze_blank])
        command.append_flag('-v', opts[:show_nonprinting])
        command.append_flag('-E', opts[:show_ends])
        command.append_flag('-b', opts[:number_nonblank])
        command.append_flag('-A', opts[:show_all])

        files = [files] if files.instance_of?(String)
        command << files.join(' ')

        append_file(command, opts)
        execute_shell(command)

        Kanrisuru::Result.new(command, &:to_a)
      end

      private

      def append_file(command, opts)
        return unless Kanrisuru::Util.present?(opts[:new_file])

        case opts[:mode]
        when 'append'
          command << ">> #{opts[:new_file]}"
        when 'write'
          command << "> #{opts[:new_file]}"
        end
      end
    end
  end
end
