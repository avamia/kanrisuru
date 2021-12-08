# frozen_string_literal: true

require_relative 'archive/types'
require_relative 'archive/commands'

module Kanrisuru
  module Core
    module Archive
      extend OsPackage::Define

      os_define :linux, :tar
    end
  end
end
