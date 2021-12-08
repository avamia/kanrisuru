module Kanrisuru
  module Core
    module User
      def get_user(user)
        command = Kanrisuru::Command.new("id #{user}")
        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          ## Get user id
          result = get_uid(user)
          break if result.failure?

          uid = result.to_i

          ## Get all groups for the user, with gid and group name
          array = Parser::Groups.parse(cmd)

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
            Parser::Getend.parse(cmd2)
          end

          ## TODO: Raise custom error to change parent result to use nested error and mark
          ## as failure.
          break if result.failure?

          home = result[0]
          shell = result[1]

          User.new(uid, user, home, shell, groups)
        end
      end
    end
  end
end
