# frozen_string_literal: true

require_relative 'dmi/types'
require_relative 'dmi/parser'
require_relative 'dmi/commands'

module Kanrisuru
  module Core
    module Dmi
      extend OsPackage::Define

      os_define :linux, :dmi
    end
  end
end
