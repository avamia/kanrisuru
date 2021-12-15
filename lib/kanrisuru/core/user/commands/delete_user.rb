# frozen_string_literal: true

module Kanrisuru
  module Core
    module User
      def delete_user(user, opts = {})
        force = opts[:force]

        return false if get_uid(user).failure?

        command = Kanrisuru::Command.new("userdel #{user}")
        command.append_flag('-f', force)

        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
