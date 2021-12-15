# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Kanrisuru::Core::IP do
  before(:all) do
    StubNetwork.stub!
  end

  after(:all) do
    StubNetwork.unstub!
  end

  let(:host) do
    Kanrisuru::Remote::Host.new(
      host: 'localhost',
      username: 'ubuntu',
      keys: ['id_rsa']
    )
  end

  it 'responds to methods' do
    expect(host).to respond_to(:ip)
  end

  it 'responds to ip fields' do
    expect(Kanrisuru::Core::IP::IPROUTE2_JSON_VERSION).to(
      eq(180_129)
    )

    expect(Kanrisuru::Core::IP::IP_ROUTE_TYPES).to(
      eq(%w[
           unicast unreachable blackhole prohibit local
           broadcast throw nat via anycast multicast
         ])
    )

    expect(Kanrisuru::Core::IP::IP_FAMILIES).to(eq(%w[inet inet6 link]))
    expect(Kanrisuru::Core::IP::IP_SCOPES).to(eq(%w[global site link host]))
    expect(Kanrisuru::Core::IP::IP_LINK_TYPES).to(
      eq(%w[
           vlan veth vcan vxcan dummy ifb macvlan macvtap
           bridge bond team ipoib ip6tnl ipip sit vxlan
           gre gretap erspan ip6gre ip6gretap ip6erspan
           vti nlmon team_slave bond_slave bridge_slave
           ipvlan ipvtap geneve vrf macsec netdevsim rmnet
           xfrm bareudp hsr
         ])
    )
    expect(Kanrisuru::Core::IP::IPLinkProperty.new).to respond_to(
      :index, :name, :flags, :mtu,
      :qdisc, :state, :group, :qlen,
      :link_mode, :link_type, :mac_address, :alias,
      :stats
    )
    expect(Kanrisuru::Core::IP::IPAddressProperty.new).to respond_to(
      :index, :name, :flags, :mtu,
      :qdisc, :state, :group, :qlen,
      :link_type, :mac_address,
      :address_info, :stats
    )
    expect(Kanrisuru::Core::IP::IPAddressInfo.new).to respond_to(
      :family, :ip, :broadcast, :scope,
      :dynamic, :valid_life_time, :preferred_life_time
    )
    expect(Kanrisuru::Core::IP::IPAddressLabel.new).to respond_to(
      :address, :prefix_length, :label
    )
    expect(Kanrisuru::Core::IP::IPRoute.new).to respond_to(
      :destination, :gateway, :device, :protocol, :scope, :preferred_source, :metric, :flags
    )
    expect(Kanrisuru::Core::IP::IPRule.new).to respond_to(:priority, :source, :table)
    expect(Kanrisuru::Core::IP::IPNeighbour.new).to respond_to(
      :destination, :device, :lladdr, :state, :stats
    )
    expect(Kanrisuru::Core::IP::IPNeighbourStats.new).to respond_to(
      :used, :confirmed, :updated, :probes, :ref_count
    )
    expect(Kanrisuru::Core::IP::IPMAddress.new).to respond_to(:index, :name, :maddr)
    expect(Kanrisuru::Core::IP::IPMAddressEntry.new).to respond_to(
      :family, :link, :address, :users
    )
    expect(Kanrisuru::Core::IP::IPStats.new).to respond_to(:rx, :tx)
    expect(Kanrisuru::Core::IP::IPStatRX.new).to respond_to(
      :bytes, :packets, :errors, :dropped, :over_errors, :multicast
    )
    expect(Kanrisuru::Core::IP::IPStatTX.new).to respond_to(
      :bytes, :packets, :errors, :dropped, :carrier_errors, :collisions
    )
  end
end
