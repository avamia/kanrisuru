module Kanrisuru
  module Core
    module User
      def create_user(user, opts = {})
        uid           = opts[:uid]
        group         = opts[:group]
        groups        = opts[:groups]
        home          = opts[:home]
        shell         = opts[:shell] || '/bin/false'
        createhome    = opts[:createhome]
        system_opt    = opts[:system]
        skeleton      = opts[:skeleton]
        non_unique    = opts[:non_unique]
        password      = opts[:password]
        expires       = opts[:expires] ## YYYY-MM-DD

        command = Kanrisuru::Command.new("useradd #{user}")

        if Kanrisuru::Util.present?(uid)
          command.append_arg('-u', uid)
          command.append_flag('-o', non_unique)
        end

        command.append_flag('-r', system_opt)
        command.append_arg('-s', shell)
        command.append_arg('-d', home)

        case createhome
        when true
          command.append_flag('-m')
          command.append_arg('-k', skeleton)
        when false
          command.append_flag('-M')
        end

        if Kanrisuru::Util.present?(group) && group?(group)
          command.append_arg('-g', group)
        elsif group?(user)
          command.append_flag('-N')
        end

        command.append_arg('-G', groups.join(',')) if Kanrisuru::Util.present?(groups)

        command.append_arg('-p', password)
        command.append_arg('-e', expires)

        execute_shell(command)

        Kanrisuru::Result.new(command) do
          get_user(user).data
        end
      end
    end
  end
end