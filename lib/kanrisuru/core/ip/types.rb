# frozen_string_literal: true

module Kanrisuru
  module Core
    module IP
      IPLinkProperty = Struct.new(
        :index, :name, :flags, :mtu,
        :qdisc, :state, :group, :qlen,
        :link_mode, :link_type, :mac_address, :alias,
        :stats
      )

      IPAddressProperty = Struct.new(
        :index, :name, :flags, :mtu,
        :qdisc, :state, :group, :qlen,
        :link_type, :mac_address,
        :address_info, :stats
      )

      IPAddressInfo = Struct.new(
        :family, :ip, :broadcast, :scope,
        :dynamic, :valid_life_time, :preferred_life_time
      )

      IPAddressLabel = Struct.new(
        :address, :prefix_length, :label
      )

      IPRoute = Struct.new(
        :destination, :gateway, :device, :protocol, :scope, :preferred_source, :metric, :flags
      )

      IPRule = Struct.new(:priority, :source, :table)

      IPNeighbour = Struct.new(:destination, :device, :lladdr, :state, :stats)
      IPNeighbourStats = Struct.new(:used, :confirmed, :updated, :probes, :ref_count)

      IPMAddress = Struct.new(:index, :name, :maddr)
      IPMAddressEntry = Struct.new(:family, :link, :address, :users)

      IPStats = Struct.new(:rx, :tx)
      IPStatRX = Struct.new(:bytes, :packets, :errors, :dropped, :over_errors, :multicast)
      IPStatTX = Struct.new(:bytes, :packets, :errors, :dropped, :carrier_errors, :collisions)
    end
  end
end
