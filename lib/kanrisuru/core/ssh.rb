# frozen_string_literal: true

require_relative 'ssh/constants'
require_relative 'ssh/parser'
require_relative 'ssh/commands'

module Kanrisuru
  module Core
    module SSH
      extend OsPackage::Define
  
      os_define :unix, :ssh_keygen 
      os_define :unix, :ssh_add 
      os_define :unix, :ssh_config

    end
  end
end
