# frozen_string_literal: true

require 'json'

require_relative 'disk/constants'

require_relative 'disk/blkid_parser'
require_relative 'disk/df_parser'
require_relative 'disk/du_parser'
require_relative 'disk/lsblk_parser'

require_relative 'disk/blkid'
require_relative 'disk/df'
require_relative 'disk/du'
require_relative 'disk/lsblk'

module Kanrisuru
  module Core
    module Disk
      include Constants
      extend OsPackage::Define

      os_define :linux, :blkid
      os_define :linux, :df
      os_define :linux, :du
      os_define :linux, :lsblk

    end
  end
end
