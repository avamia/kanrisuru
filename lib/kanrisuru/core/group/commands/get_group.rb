module Kanrisuru
  module Core
    module Group
      def get_group(group)
        command = Kanrisuru::Command.new("getent group #{group} | cut -d: -f4")

        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          ## Get group id
          result = get_gid(group)
          break if result.failure?

          gid = result.to_i
          
          users = Parser::Group.parse(cmd)
          users = users.map do |user|
            uid = get_uid(user)
            GroupUser.new(uid.to_i, user)
          end

          Group.new(gid, group, users)
        end
      end
    end
  end
end
