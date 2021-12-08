# frozen_string_literal: true

require 'date'

require_relative 'file/types'
require_relative 'file/parser'
require_relative 'file/commands'

module Kanrisuru
  module Core
    module File
      extend OsPackage::Define

      os_define :linux, :touch
      os_define :linux, :cp
      os_define :linux, :copy
      os_define :linux, :mkdir
      os_define :linux, :mv
      os_define :linux, :move

      os_define :linux, :link
      os_define :linux, :symlink
      os_define :linux, :ln
      os_define :linux, :ln_s

      os_define :linux, :chmod
      os_define :linux, :chown

      os_define :linux, :unlink
      os_define :linux, :rm
      os_define :linux, :rmdir

      os_define :linux, :wc
    end
  end
end
