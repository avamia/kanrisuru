# frozen_string_literal: true

module Kanrisuru
  module Core
    module Path
      FilePath = Struct.new(:path)
      FileInfoId = Struct.new(:inode, :mode, :hard_links, :uid, :gid, :fsize, :date, :path, :type)
      FileInfo = Struct.new(:inode, :mode, :hard_links, :owner, :group, :fsize, :date, :path, :type)
      UserName = Struct.new(:user)
    end
  end
end
