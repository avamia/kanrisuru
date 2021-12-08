# frozen_string_literal: true

require 'date'

require_relative 'path/types'
require_relative 'path/parser'
require_relative 'path/commands'

module Kanrisuru
  module Core
    module Path
      extend OsPackage::Define

      os_define :linux, :ls
      os_define :linux, :pwd
      os_define :linux, :realpath
      os_define :linux, :readlink
      os_define :linux, :whoami
      os_define :linux, :which
    end
  end
end
