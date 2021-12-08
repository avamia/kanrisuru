# frozen_string_literal: true

require_relative 'user/types'
require_relative 'user/parser'
require_relative 'user/commands'

module Kanrisuru
  module Core
    module User
      extend OsPackage::Define

      os_define :linux, :user?
      os_define :linux, :get_uid
      os_define :linux, :get_user
      os_define :linux, :create_user
      os_define :linux, :update_user
      os_define :linux, :delete_user
    end
  end
end
