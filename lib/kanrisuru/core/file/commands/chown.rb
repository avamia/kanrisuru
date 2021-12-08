# frozen_string_literal: true

module Kanrisuru
  module Core
    module File
      def chown(path, opts = {})
        owner = opts[:owner]
        group = opts[:group]

        uid = get_uid(owner).to_i if Kanrisuru::Util.present?(owner)
        gid = get_gid(group).to_i if Kanrisuru::Util.present?(group)

        ## Don't chown a blank owner and group.
        return false if Kanrisuru::Util.blank?(uid) && Kanrisuru::Util.blank?(gid)

        command = Kanrisuru::Command.new('chown')

        arg = ''
        arg = uid.to_s if Kanrisuru::Util.present?(uid)
        arg += ":#{gid}" if Kanrisuru::Util.present?(gid)

        command.append_value(arg)
        command.append_flag('-R', opts[:recursive])

        command << path

        execute_shell(command)

        Kanrisuru::Result.new(command) do
          stat(path).data
        end
      end
    end
  end
end
