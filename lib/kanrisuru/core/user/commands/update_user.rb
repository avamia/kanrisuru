# frozen_string_literal: true

module Kanrisuru
  module Core
    module User
      def update_user(user, opts = {})
        uid           = opts[:uid]
        group         = opts[:group]
        groups        = opts[:groups]
        append        = opts[:append]
        home          = opts[:home]
        move_home     = opts[:move_home]
        shell         = opts[:shell] || '/bin/false'
        non_unique    = opts[:non_unique]
        password      = opts[:password]
        expires       = opts[:expires] ## YYYY-MM-DD
        locked        = opts[:locked]

        command = Kanrisuru::Command.new("usermod #{user}")

        if Kanrisuru::Util.present?(home)
          command.append_arg('-d', home)
          command.append_flag('-m', move_home)
        end

        command.append_arg('-s', shell)

        if Kanrisuru::Util.present?(uid)
          command.append_arg('-u', uid)
          command.append_flag('-o', non_unique)
        end

        command.append_arg('-g', group) if Kanrisuru::Util.present?(group) && group_exists?(group)

        if Kanrisuru::Util.present?(groups)
          command.append_arg('-G', groups.join(','))
          command.append_flag('-a', append)
        end

        case locked
        when true
          command.append_flag('-L')
          command.append_arg('-e', 1)
        when false
          command.append_arg('-U')
          command.append_arg('-e', 99_999)
        else
          ## Ensure expires isn't added twice.
          command.append_arg('-e', expires)

          ## Can't use password with lock / unlock flag.
          command.append_arg('-p', password)
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do |_command|
          get_user(user).data
        end
      end
    end
  end
end
