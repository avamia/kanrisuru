# frozen_string_literal: true

require_relative 'group/types'
require_relative 'group/parser'
require_relative 'group/commands'

module Kanrisuru
  module Core
    module Group
      extend OsPackage::Define

      os_define :linux, :group?
      os_define :linux, :get_gid
      os_define :linux, :get_group
      os_define :linux, :create_group
      os_define :linux, :update_group
      os_define :linux, :delete_group
    end
  end
end
