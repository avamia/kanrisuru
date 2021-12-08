# frozen_string_literal: true

require 'ipaddr'

require_relative 'socket/constants'
require_relative 'socket/types'
require_relative 'socket/parser'
require_relative 'socket/commands'

module Kanrisuru
  module Core
    module Socket
      extend OsPackage::Define

      os_define :linux, :ss
    end
  end
end
