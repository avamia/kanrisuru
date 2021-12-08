# frozen_string_literal: true

module Kanrisuru
  module Core
    module Group
      def update_group(group, opts = {})
        gid = opts[:gid]
        return if Kanrisuru::Util.blank?(gid) || Kanrisuru::Util.blank?(opts[:new_name])

        command = Kanrisuru::Command.new("groupmod #{group}")
        command.append_arg('-g', gid)
        command.append_arg('-n', opts[:new_name])

        execute_shell(command)

        Kanrisuru::Result.new(command) do
          gid = Kanrisuru::Util.present?(gid) ? gid : get_gid(group).data
          Group.new(gid, group)
        end
      end
    end
  end
end
