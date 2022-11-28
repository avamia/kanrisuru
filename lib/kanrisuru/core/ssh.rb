# frozen_string_literal: true

require_relative 'ssh/constants'
require_relative 'ssh/parser'
require_relative 'ssh/commands'

module Kanrisuru
  module Core
    module SSHKeygen
      extend OsPackage::Define
  
      os_define :linux, :ssh_keygen 
      os_define :linux, :ssh_add 
      os_define :linux, :ssh_config

    end
  end
end
