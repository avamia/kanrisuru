# frozen_string_literal: true

module Kanrisuru
  module Core
    module Stat
      FileStat = Struct.new(
        :mode, :blocks, :device, :file_type,
        :gid, :group, :links, :inode,
        :path, :fsize, :uid, :user,
        :last_access, :last_modified, :last_changed
      )
    end
  end
end
