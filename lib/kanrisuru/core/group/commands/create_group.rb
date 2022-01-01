# frozen_string_literal: true

module Kanrisuru
  module Core
    module Group
      def create_group(group, opts = {})
        gid = opts[:gid]

        command = Kanrisuru::Command.new("groupadd #{group}")
        command.append_arg('-g', gid)
        command.append_flag('-o', opts[:non_unique])
        command.append_flag('-r', opts[:system])

        execute_shell(command)

        Kanrisuru::Result.new(command) do
          gid = Kanrisuru::Util.present?(gid) ? gid : get_gid(group).data
          Group.new(gid, group)
        end
      end
    end
  end
end
