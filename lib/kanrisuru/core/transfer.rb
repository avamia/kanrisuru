# frozen_string_literal: true

require 'uri'

require_relative 'transfer/constants'
require_relative 'transfer/commands'

module Kanrisuru
  module Core
    module Transfer
      extend OsPackage::Define

      os_define :linux, :download
      os_define :linux, :upload
      os_define :linux, :wget
    end
  end
end
