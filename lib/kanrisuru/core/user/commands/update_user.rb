# frozen_string_literal: true

module Kanrisuru
  module Core
    module User
      def update_user(user, opts = {})
        group         = opts[:group]
        groups        = opts[:groups]

        command = Kanrisuru::Command.new("usermod #{user}")

        if Kanrisuru::Util.present?(opts[:home])
          command.append_arg('-d', opts[:home])
          command.append_flag('-m', opts[:move_home])
        end

        command.append_arg('-s', opts[:shell])

        if Kanrisuru::Util.present?(opts[:uid])
          command.append_arg('-u', opts[:uid])
          command.append_flag('-o', opts[:non_unique])
        end

        command.append_arg('-g', group) if Kanrisuru::Util.present?(group) && group?(group)

        if Kanrisuru::Util.present?(groups)
          command.append_arg('-G', Kanrisuru::Util.array_join_string(groups, ','))
          command.append_flag('-a', opts[:append])
        end

        case opts[:locked]
        when true
          command.append_flag('-L')
          command.append_arg('-e', 1)
        when false
          command.append_flag('-U')
          command.append_arg('-e', 99_999)
        else
          ## Ensure expires isn't added twice.
          command.append_arg('-e', opts[:expires]) ## YYYY-MM-DD

          ## Can't use password with lock / unlock flag.
          command.append_arg('-p', opts[:password])
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do |_command|
          get_user(user).data
        end
      end
    end
  end
end
