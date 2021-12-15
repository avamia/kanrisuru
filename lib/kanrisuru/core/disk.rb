# frozen_string_literal: true

require 'json'

require_relative 'disk/constants'
require_relative 'disk/types'
require_relative 'disk/parser'
require_relative 'disk/commands'

module Kanrisuru
  module Core
    module Disk
      extend OsPackage::Define

      os_define :linux, :blkid
      os_define :linux, :df
      os_define :linux, :du
      os_define :linux, :lsblk
    end
  end
end
