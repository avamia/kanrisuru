# frozen_string_literal: true

module Kanrisuru
  module Core
    module User
      extend OsPackage::Define

      os_define :linux, :user?
      os_define :linux, :get_uid
      os_define :linux, :get_user
      os_define :linux, :create_user
      os_define :linux, :update_user
      os_define :linux, :delete_user

      User = Struct.new(:uid, :name, :home, :shell, :groups)
      UserGroup = Struct.new(:gid, :name)
      FilePath = Struct.new(:path)

      def user?(user)
        result = get_uid(user)
        return false if result.failure?

        Kanrisuru::Util.present?(result.data) && result.data.instance_of?(Integer)
      end

      def get_uid(user)
        command = Kanrisuru::Command.new("id -u #{user}")

        execute(command)

        Kanrisuru::Result.new(command, &:to_i)
      end

      def get_user(user)
        command = Kanrisuru::Command.new("id #{user}")
        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          ## Get user id
          result = get_uid(user)
          break if result.failure?

          uid = result.to_i

          ## Get all groups for the user, with gid and group name
          string = cmd.to_s
          string = string.split('groups=')[1]
          array = string.gsub(/\(/, '').gsub(/\)/, '').split(',')

          groups = array.map do |str|
            gid  = str.delete('^0-9').to_i
            name = str.delete('0-9')

            UserGroup.new(gid, name)
          end

          ## Get home / shell path information
          cmd = Kanrisuru::Command.new("getent passwd #{user}")
          cmd | "awk -F: '{print $6, $7}'"

          execute(cmd)

          result = Kanrisuru::Result.new(cmd) do |cmd2|
            cmd2.to_s.split.map { |value| FilePath.new(value) }
          end

          ## TODO: Raise custom error to change parent result to use nested error and mark
          ## as failure.
          break if result.failure?

          home = result[0]
          shell = result[1]

          User.new(uid, user, home, shell, groups)
        end
      end

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

      def delete_user(user, opts = {})
        force = opts[:force]

        return false unless get_uid(user)

        command = Kanrisuru::Command.new("userdel #{user}")
        command.append_flag('-f', force)

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
