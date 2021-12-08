# frozen_string_literal: true

require_relative 'archive/constants'
require_relative 'archive/tar'

module Kanrisuru
  module Core
    module Archive
      include Constants
      extend OsPackage::Define

      os_define :linux, :tar
      
    end
  end
end
