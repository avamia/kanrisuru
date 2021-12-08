# frozen_string_literal: true

require 'date'

require_relative 'stat/types'
require_relative 'stat/parser'
require_relative 'stat/commands'

module Kanrisuru
  module Core
    module Stat
      extend OsPackage::Define

      os_define :linux, :dir?
      os_define :linux, :file?
      os_define :linux, :block_device?
      os_define :linux, :char_device?
      os_define :linux, :symlink?
      os_define :linux, :file_type?
      os_define :linux, :inode?
      os_define :linux, :stat
    end
  end
end
