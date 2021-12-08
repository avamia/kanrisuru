module Kanrisuru
  module Core
    module User
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