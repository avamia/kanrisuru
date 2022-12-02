# frozen_string_literal: true

require_relative 'core/path'
require_relative 'core/system'
require_relative 'core/disk'
require_relative 'core/mount'
require_relative 'core/stat'
require_relative 'core/find'
require_relative 'core/file'
require_relative 'core/group'
require_relative 'core/user'
require_relative 'core/archive'
require_relative 'core/stream'
require_relative 'core/transfer'
require_relative 'core/ip'
require_relative 'core/socket'
require_relative 'core/apt'
require_relative 'core/yum'
require_relative 'core/zypper'
require_relative 'core/dmi'
require_relative 'core/ssh'

module Kanrisuru
  module Local
    class Host
      os_include Kanrisuru::Core::SSH
    end
  end

  module Remote
    class Host
      os_include Kanrisuru::Core::Path
      os_include Kanrisuru::Core::System
      os_include Kanrisuru::Core::Disk
      os_include Kanrisuru::Core::Mount
      os_include Kanrisuru::Core::Stat
      os_include Kanrisuru::Core::Find
      os_include Kanrisuru::Core::File
      os_include Kanrisuru::Core::Group
      os_include Kanrisuru::Core::User
      os_include Kanrisuru::Core::Archive
      os_include Kanrisuru::Core::Stream
      os_include Kanrisuru::Core::Transfer
      os_include Kanrisuru::Core::IP
      os_include Kanrisuru::Core::Socket
      os_include Kanrisuru::Core::Apt
      os_include Kanrisuru::Core::Yum
      os_include Kanrisuru::Core::Zypper
      os_include Kanrisuru::Core::Dmi
    end

    class Cluster
      os_collection Kanrisuru::Core::Path
      os_collection Kanrisuru::Core::System
      os_collection Kanrisuru::Core::Disk
      os_collection Kanrisuru::Core::Mount
      os_collection Kanrisuru::Core::Stat
      os_collection Kanrisuru::Core::File
      os_collection Kanrisuru::Core::Group
      os_collection Kanrisuru::Core::User
      os_collection Kanrisuru::Core::Archive
      os_collection Kanrisuru::Core::Stream
      os_collection Kanrisuru::Core::Transfer
      os_collection Kanrisuru::Core::IP
      os_collection Kanrisuru::Core::Socket
      os_collection Kanrisuru::Core::Apt
      os_collection Kanrisuru::Core::Yum
      os_collection Kanrisuru::Core::Zypper
      os_collection Kanrisuru::Core::Dmi
    end
  end
end
