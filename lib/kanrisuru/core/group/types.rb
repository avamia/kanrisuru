module Kanrisuru
  module Core
    module Group
      Group = Struct.new(:gid, :name, :users)
      GroupUser = Struct.new(:uid, :name)
    end
  end
end
