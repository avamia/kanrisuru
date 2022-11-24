# frozen_string_literal: true

require_relative 'ssh-keygen/constants'
require_relative 'ssh-keygen/commands'

module Kanrisuru
  module Core
    module SSHKeygen
      extend OsPackage::Define
  
      os_define :linux, :ssh_keygen       
    end
  end
end
