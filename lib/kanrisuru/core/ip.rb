# frozen_string_literal: true

require 'ipaddr'

require_relative 'ip/constants'
require_relative 'ip/types'
require_relative 'ip/parser'
require_relative 'ip/commands'

module Kanrisuru
  module Core
    module IP
      extend OsPackage::Define

      os_define :linux, :ip

      def ip(object, action = nil, opts = {})
        if action.instance_of?(Hash)
          opts = action || {}
          action = 'show'
        elsif action.nil?
          action = 'show'
          opts = {}
        end

        case object
        when 'address', 'addr', 'a'
          ip_address(action, opts)
        when 'addrlabel', 'addrl'
          ip_address_label(action, opts)
        when 'link', 'l'
          ip_link(action, opts)
        when 'maddress', 'maddr', 'm'
          ip_maddress(action, opts)
        when 'neighbour', 'neigh', 'n'
          ip_neighbour(action, opts)
        when 'route', 'r', 'ro', 'rou', 'rout'
          ip_route(action, opts)
        when 'rule', 'ru'
          ip_rule(action, opts)
        end
      end
    end
  end
end
