# frozen_string_literal: true

module Kanrisuru
  module Core
    module Group
      extend OsPackage::Define

      os_define :linux, :group?
      os_define :linux, :get_gid
      os_define :linux, :get_group
      os_define :linux, :create_group
      os_define :linux, :update_group
      os_define :linux, :delete_group

      Group = Struct.new(:gid, :name, :users)
      GroupUser = Struct.new(:uid, :name)

      def group?(group)
        result = get_gid(group)
        return false if result.failure?

        Kanrisuru::Util.present?(result.data) && result.data.instance_of?(Integer)
      end

      def get_gid(group)
        command = Kanrisuru::Command.new("getent group #{group}")

        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          cmd.to_s.split(':')[2].to_i
        end
      end

      def get_group(group)
        command = Kanrisuru::Command.new("getent group #{group} | cut -d: -f4")

        execute(command)

        Kanrisuru::Result.new(command) do |cmd|
          ## Get group id
          result = get_gid(group)
          break if result.failure?

          gid = result.to_i

          array = cmd.to_s.split(',')
          users = array.map do |user|
            uid = get_uid(user)
            GroupUser.new(uid.to_i, user)
          end

          Group.new(gid, group, users)
        end
      end

      def create_group(group, opts = {})
        gid = opts[:gid]

        command = Kanrisuru::Command.new("groupadd #{group}")
        command.append_arg('-g', gid)

        execute_shell(command)

        Kanrisuru::Result.new(command) do
          gid = Kanrisuru::Util.present?(gid) ? gid : get_gid(group).data
          Group.new(gid, group)
        end
      end

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

      def delete_group(group)
        return false unless group?(group)

        command = Kanrisuru::Command.new("groupdel #{group}")
        execute_shell(command)

        Kanrisuru::Result.new(command)
      end
    end
  end
end
