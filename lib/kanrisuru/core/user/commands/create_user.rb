# frozen_string_literal: true

module Kanrisuru
  module Core
    module User
      def create_user(user, opts = {})
        group         = opts[:group]
        groups        = opts[:groups]
        shell         = opts[:shell] || '/bin/false'

        command = Kanrisuru::Command.new("useradd #{user}")

        if Kanrisuru::Util.present?(opts[:uid])
          command.append_arg('-u', opts[:uid])
          command.append_flag('-o', opts[:non_unique])
        end

        command.append_flag('-r', opts[:system])
        command.append_arg('-s', shell)
        command.append_arg('-d', opts[:home])

        case opts[:createhome]
        when true
          command.append_flag('-m')
          command.append_arg('-k', opts[:skeleton])
        when false
          command.append_flag('-M')
        end

        if Kanrisuru::Util.present?(group) && group?(group)
          command.append_arg('-g', group)
        elsif group?(user)
          command.append_flag('-N')
        end

        command.append_arg('-G', groups.join(',')) if Kanrisuru::Util.present?(groups)

        command.append_arg('-p', opts[:password])
        command.append_arg('-e', opts[:expires]) ## YYYY-MM-DD

        execute_shell(command)

        Kanrisuru::Result.new(command) do
          get_user(user).data
        end
      end
    end
  end
end
