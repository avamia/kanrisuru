module Kanrisuru
  module Core
    module User
      User = Struct.new(:uid, :name, :home, :shell, :groups)
      UserGroup = Struct.new(:gid, :name)
      FilePath = Struct.new(:path)
    end
  end
end
