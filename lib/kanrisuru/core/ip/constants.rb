# frozen_string_literal: true

module Kanrisuru
  module Core
    module IP
      IPROUTE2_JSON_VERSION = 180_129
      IP_ROUTE_TYPES = %w[
        unicast unreachable blackhole prohibit local
        broadcast throw nat via anycast multicast
      ].freeze
    end
  end
end
