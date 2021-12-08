# frozen_string_literal: true

require 'date'
require 'ipaddr'

require_relative 'system/types'
require_relative 'system/parser'
require_relative 'system/commands'

module Kanrisuru
  module Core
    module System
      extend OsPackage::Define

      os_define :linux, :load_env
      os_define :linux, :cpu_info
      os_define :linux, :lscpu
      os_define :linux, :load_average
      os_define :linux, :free
      os_define :linux, :ps
      os_define :linux, :kill
      os_define :linux, :kernel_statistics
      os_define :linux, :kstat
      os_define :linux, :lsof
      os_define :linux, :last
      os_define :linux, :uptime
      os_define :linux, :w
      os_define :linux, :who
      os_define :linux, :reboot
      os_define :linux, :poweroff
    end
  end
end
