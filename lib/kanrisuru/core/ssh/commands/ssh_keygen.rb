# frozen_string_literal: true

module Kanrisuru
  module Core
    module SSH
      def ssh_keygen(opts = {}) 
        command = Kanrisuru::Command.new('ssh-keygen')
        filename = Kanrisuru::Util.present?(opts[:filename]) ? 
          opts[:filename] : '~/.ssh/id_rsa'

        if Kanrisuru::Util.present?(opts[:type])
          raise ArgumentError, 'invalid keygen type' unless KEY_TYPES.include?(opts[:type])
          command.append_arg('-t', opts[:type])
        end

        command.append_arg('-a', opts[:rounds])
        command.append_flag('-B', opts[:bubblebabble])
        command.append_flag('-b', opts[:bits])

        if Kanrisuru::Util.present?(opts[:password])
          command.append_arg('-N', opts[:password])
        else
          command.append_arg('-N', "''")
        end

        command.append_arg('-f', filename)

        ## Append here-string to auto answer yes
        command << '<<< y'

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          if cmd.success?
            key_file = filename
            result = download(key_file, opts[:local_path])

            rm(key_file)

            return result
          end
        end
      end
    end
  end
end
