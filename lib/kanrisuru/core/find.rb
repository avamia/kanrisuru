# frozen_string_literal: true

require 'date'

require_relative 'find/constants'
require_relative 'find/types'
require_relative 'find/parser'
require_relative 'find/commands'

module Kanrisuru
  module Core
    module Find
      extend OsPackage::Define

      os_define :linux, :find
    end
  end
end
