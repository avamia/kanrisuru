module Kanrisuru
  module Core
    module Stream
      def sed(path, expression, replacement, opts = {})
        command = Kanrisuru::Command.new('sed')
        command.append_flag('-i', opts[:in_place])
        command.append_flag('-r', opts[:regexp_extended])

        command << "'s/#{expression}/#{replacement}/g'"
        command << "'#{path}'"

        append_file(command, opts)
        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|

        end
      end
    end
  end
end
