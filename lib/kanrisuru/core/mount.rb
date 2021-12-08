# frozen_string_literal: true

require_relative 'mount/commands'

module Kanrisuru
  module Core
    module Mount
      extend OsPackage::Define

      os_define :linux, :mount
      os_define :linux, :umount
    end
  end
end
