# frozen_string_literal: true

require_relative 'dmi/constants'
require_relative 'dmi/dmi_parser'
require_relative 'dmi/dmi'

module Kanrisuru
  module Core
    module Dmi
      include Constants
      extend OsPackage::Define

      os_define :linux, :dmi

    end
  end
end
