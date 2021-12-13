# frozen_string_literal: true

module Kanrisuru
  module Core
    module IP
      IPROUTE2_JSON_VERSION = 180_129

      IP_ROUTE_TYPES = %w[
        unicast unreachable blackhole prohibit local
        broadcast throw nat via anycast multicast
      ].freeze

      IP_FAMILIES = %w[inet inet6 link].freeze
      IP_SCOPES = %w[global site link host].freeze
      IP_LINK_TYPES = %w[
        vlan veth vcan vxcan dummy ifb macvlan macvtap
        bridge bond team ipoib ip6tnl ipip sit vxlan
        gre gretap erspan ip6gre ip6gretap ip6erspan
        vti nlmon team_slave bond_slave bridge_slave
        ipvlan ipvtap geneve vrf macsec netdevsim rmnet
        xfrm bareudp hsr
      ].freeze
    end
  end
end
