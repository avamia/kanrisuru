# frozen_string_literal: true

require 'ipaddr'

module Kanrisuru
  module Core
    module IP
      extend OsPackage::Define

      IPROUTE2_JSON_VERSION = 180_129

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

      IP_ROUTE_TYPES = %w[
        unicast unreachable blackhole prohibit local
        broadcast throw nat via anycast multicast
      ].freeze

      IPStats = Struct.new(:rx, :tx)
      IPStatRX = Struct.new(:bytes, :packets, :errors, :dropped, :over_errors, :multicast)
      IPStatTX = Struct.new(:bytes, :packets, :errors, :dropped, :carrier_errors, :collisions)

      os_define :linux, :ip

      def ip(object, action = nil, opts = {})
        if action.instance_of?(Hash)
          opts = action
          action = 'show'
        end

        case object
        when 'link', 'l'
          ip_link(action, opts)
        when 'address', 'addr', 'a'
          ip_address(action, opts)
        when 'addrlabel', 'addrl'
          ip_address_label(action, opts)
        when 'route', 'r', 'ro', 'rou', 'rout'
          ip_route(action, opts)
        when 'rule', 'ru'
          ip_rule(action, opts)
        when 'neighbour', 'neigh', 'n'
          ip_neighbour(action, opts)
        when 'maddress', 'maddr', 'm'
          ip_maddress(action, opts)
        end
      end

      private

      def ip_version
        command = Kanrisuru::Command.new('ip -V')
        execute_shell(command)

        raise 'ip command not found' if command.failure?

        command.to_s.split('ip utility, iproute2-ss')[1].to_i
      end

      def ip_link(action, opts)
        command = nil

        case action
        when 'show', 'list'
          version = ip_version

          command = Kanrisuru::Command.new('ip')
          command.append_flag('-json') if version >= IPROUTE2_JSON_VERSION
          command.append_flag('-s', opts[:stats])
          command.append_arg('-family', opts[:family])
          command << 'link show'

          command.append_arg('dev', opts[:dev])
          command.append_arg('group', opts[:group])
          command.append_arg('master', opts[:master])
          command.append_arg('type', opts[:type])
          command.append_arg('vrf', opts[:vrf])

          command.append_flag('up', opts[:up])
        when 'set'
          command = Kanrisuru::Command.new('ip link set')

          raise ArgumentError, 'no device defined' unless opts[:dev]

          command.append_arg('dev', opts[:dev])

          case opts[:direction]
          when 'up'
            command.append_flag('up')
          when 'down'
            command.append_flag('down')
          end

          command.append_arg('arp', opts[:arp])
          command.append_arg('multicast', opts[:multicast])
          command.append_arg('dynamic', opts[:dynamic])
          command.append_arg('name', opts[:name])
          command.append_arg('txqueuelen', opts[:txqueuelen])
          command.append_arg('txqlen', opts[:txqlen])
          command.append_arg('mtu', opts[:mtu])
          command.append_arg('address', opts[:address])
          command.append_arg('broadcast', opts[:broadcast])
          command.append_arg('brd', opts[:brd])
          command.append_arg('peer', opts[:peer])
          command.append_arg('netns', opts[:netns])

          if Kanrisuru::Util.present?(opts[:vf])
            command.append_arg('vf', opts[:vf])
            command.append_arg('mac', opts[:mac])

            if Kanrisuru::Util.present?(opts[:vlan])
              command.append_arg('vlan', opts[:vlan])
              command.append_arg('qos', opts[:qos])
            end

            command.append_arg('rate', opts[:rate])
          end
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          if %w[show list].include?(action)
            if version >= IPROUTE2_JSON_VERSION
              begin
                ip_link_result_json(cmd.to_json)
              rescue JSON::ParserError
                ip_link_result_parse(cmd.to_a)
              end
            else
              ip_link_result_parse(cmd.to_a)
            end
          end
        end
      end

      def ip_address(action, opts)
        command = nil

        case action
        when 'show', 'list'
          version = ip_version

          command = Kanrisuru::Command.new('ip')
          command.append_flag('-json') if version >= IPROUTE2_JSON_VERSION
          command.append_flag('-s', opts[:stats])
          command.append_arg('-family', opts[:family])
          command << 'address show'

          command.append_arg('dev', opts[:dev])
          command.append_arg('scope', opts[:scope])
          command.append_arg('to', opts[:prefix])
          command.append_arg('label', opts[:label])

          command.append_flag('dynamic', opts[:dynamic])
          command.append_flag('permanent', opts[:permanent])
          command.append_flag('tenative', opts[:tenative])
          command.append_flag('deprecated', opts[:deprecated])
          command.append_flag('primary', opts[:primary])
          command.append_flag('secondary', opts[:secondary])
          command.append_flag('up', opts[:up])
        when 'add'
          command = Kanrisuru::Command.new('ip address add')
          command << opts[:address]

          command.append_arg('dev', opts[:dev])
          command.append_arg('label', opts[:label])
          command.append_arg('scope', opts[:scope])
        when 'del', 'delete'
          command = Kanrisuru::Command.new('ip address del')
          command << opts[:address]

          command.append_arg('dev', opts[:dev])
          command.append_arg('label', opts[:label])
          command.append_arg('scope', opts[:scope])
        when 'flush'
          command = Kanrisuru::Command.new('ip address flush')

          command.append_arg('dev', opts[:dev])
          command.append_arg('scope', opts[:scope])
          command.append_arg('to', opts[:prefix])
          command.append_arg('label', opts[:label])

          command.append_flag('dynamic', opts[:dynamic])
          command.append_flag('permanent', opts[:permanent])
          command.append_flag('tenative', opts[:tenative])
          command.append_flag('deprecated', opts[:deprecated])
          command.append_flag('primary', opts[:primary])
          command.append_flag('secondary', opts[:secondary])
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          if %w[show list].include?(action)
            if version >= IPROUTE2_JSON_VERSION
              begin
                ip_address_result_json(cmd.to_json)
              rescue JSON::ParserError
                ip_address_result_parse(cmd.to_a)
              end
            else
              ip_address_result_parse(cmd.to_a)
            end
          end
        end
      end

      def ip_address_label(action, opts)
        command = nil

        case action
        when 'show', 'list'
          version = ip_version

          command = Kanrisuru::Command.new('ip')
          command.append_flag('-json') if version >= IPROUTE2_JSON_VERSION
          command << 'addrlabel list'
        when 'flush'
          command = Kanrisuru::Command.new('ip addrlabel flush')
        when 'add'
          command = Kanrisuru::Command.new('ip addrlabel add')
          command.append_arg('prefix', opts[:prefix])
          command.append_arg('dev', opts[:dev])
          command.append_arg('label', opts[:label])
        when 'del'
          command = Kanrisuru::Command.new('ip addrlabel del')
          command.append_arg('prefix', opts[:prefix])
          command.append_arg('dev', opts[:dev])
          command.append_arg('label', opts[:label])
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          if %w[show list].include?(action)
            if version >= IPROUTE2_JSON_VERSION
              begin
                ip_address_label_result_json(cmd.to_json)
              rescue JSON::ParserError
                ip_address_label_result_parse(cmd.to_a)
              end
            else
              ip_address_label_result_parse(cmd.to_a)
            end
          end
        end
      end

      def ip_route(action, opts)
        case action
        when 'show', 'list'
          version = ip_version

          command = Kanrisuru::Command.new('ip')
          command.append_flag('-json') if version >= IPROUTE2_JSON_VERSION
          command.append_arg('-family', opts[:family])
          command << 'route show'

          command.append_arg('to', opts[:to])
          command.append_arg('dev', opts[:dev])
          command.append_arg('proto', opts[:proto])
          command.append_arg('type', opts[:type])
          command.append_arg('via', opts[:via])
          command.append_arg('src', opts[:src])
          command.append_arg('realms', opts[:realms])
        when 'flush'
          command = Kanrisuru::Command.new('ip')
          command.append_arg('-family', opts[:family])
          command << 'route flush'

          command.append_arg('to', opts[:to])
          command.append_arg('dev', opts[:dev])
          command.append_arg('proto', opts[:proto])
          command.append_arg('type', opts[:type])
          command.append_arg('via', opts[:via])
          command.append_arg('src', opts[:src])
          command.append_arg('realm', opts[:realm])
          command.append_arg('realms', opts[:realm])
        when 'add', 'change', 'append', 'del', 'delete'
          command = Kanrisuru::Command.new('ip route')
          command << action

          command.append_arg('to', opts[:to])
          command.append_arg('tos', opts[:tos])
          command.append_arg('dsfield', opts[:dsfield])
          command.append_arg('metric', opts[:metric])
          command.append_arg('preference', opts[:preference])
          command.append_arg('table', opts[:table])
          command.append_arg('vrf', opts[:vrf])
          command.append_arg('dev', opts[:dev])
          command.append_arg('via', opts[:via])
          command.append_arg('src', opts[:src])
          command.append_arg('realm', opts[:realm])

          command.append_arg('mtu', opts[:mtu])
          command.append_arg('window', opts[:window])
          command.append_arg('rtt', opts[:rtt])
          command.append_arg('rttvar', opts[:rttvar])
          command.append_arg('rto_min', opts[:rto_min])
          command.append_arg('ssthresh', opts[:ssthresh])
          command.append_arg('cwnd', opts[:cwnd])
          command.append_arg('initcwnd', opts[:initcwnd])
          command.append_arg('initrwnd', opts[:initrwnd])
          command.append_arg('features', opts[:features])
          command.append_arg('quickack', opts[:quickack])
          command.append_arg('fastopen_no_cookie', opts[:fastopen_no_cookie])

          if Kanrisuru::Util.present?(opts[:congctl])
            if Kanrisuru::Util.present?(opts[:congctl_lock])
              command.append_arg('congctl', opts[:congctl])
            else
              command.append_arg('congctl lock', opts[:congctl])
            end
          end

          command.append_arg('advmss', opts[:advmss])
          command.append_arg('reordering', opts[:reordering])

          if Kanrisuru::Util.present?(opts[:next_hop])
            next_hop = opts[:next_hop]

            command << 'next_hop'
            command.append_arg('via', next_hop[:via])
            command.append_arg('dev', next_hop[:dev])
            command.append_arg('weight', next_hop[:weight])
          end

          command.append_arg('scope', opts[:scope])
          command.append_arg('protocol', opts[:protocol])
          command.append_flag('onlink', opts[:onlink])
          command.append_arg('pref', opts[:pref])
        when 'get'
          command = Kanrisuru::Command.new('ip route get')

          command.append_arg('to', opts[:to])
          command.append_arg('from', opts[:from])
          command.append_arg('tos', opts[:tos])
          command.append_arg('dsfield', opts[:dsfield])
          command.append_arg('iif', opts[:iif])
          command.append_arg('oif', opts[:oif])
          command.append_arg('mark', opts[:mark])
          command.append_arg('vrf', opts[:vrf])
          command.append_arg('ipproto', opts[:ipproto])
          command.append_arg('sport', opts[:sport])
          command.append_arg('dport', opts[:dport])

          command.append_flag('connected', opts[:connected])
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          if %w[show list].include?(action)
            if version >= IPROUTE2_JSON_VERSION
              begin
                ip_route_result_json(cmd.to_json)
              rescue JSON::ParserError
                ip_route_result_parse(cmd.to_a)
              end
            else
              ip_route_result_parse(cmd.to_a)
            end
          end
        end
      end

      def ip_rule(action, opts)
        case action
        when 'show', 'list'
          version = ip_version

          command = Kanrisuru::Command.new('ip')
          command.append_flag('-json') if version >= IPROUTE2_JSON_VERSION

          command << 'rule show'
        when 'flush'
          command = Kanrisuru::Command.new('ip rule flush')
        when 'add', 'delete'
          command = Kanrisuru::Command.new('ip rule')
          command << action

          command.append_arg('type', opts[:type])
          command.append_arg('from', opts[:from])
          command.append_arg('to', opts[:to])
          command.append_arg('iif', opts[:iif])
          command.append_arg('tos', opts[:tos])
          command.append_arg('dsfield', opts[:dsfield])
          command.append_arg('fwmark', opts[:fwmark])
          command.append_arg('priority', opts[:priority])
          command.append_arg('table', opts[:table])
          command.append_arg('realms', opts[:realms])
          command.append_arg('nat', opts[:nat])
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          if %w[show list].include?(action)
            if version >= IPROUTE2_JSON_VERSION
              begin
                ip_rule_result_json(cmd.to_json)
              rescue JSON::ParserError
                ip_rule_result_parse(cmd.to_a)
              end
            else
              ip_rule_result_parse(cmd.to_a)
            end
          end
        end
      end

      def ip_neighbour(action, opts)
        case action
        when 'add', 'change', 'replace', 'del', 'delete'
          command = Kanrisuru::Command.new('ip neighbour')
          command << action

          command.append_arg('to', opts[:to])
          command.append_arg('dev', opts[:dev])

          if action != 'del' && action != 'delete'
            command.append_arg('lladdr', opts[:lladdr])
            command.append_arg('nud', opts[:nud])
          end

          command.append_flag('permanent', opts[:permanent])
          command.append_flag('noarp', opts[:noarp])
          command.append_flag('reachable', opts[:reachable])
          command.append_flag('stale', opts[:stale])
        when 'show', 'list'
          version = ip_version

          command = Kanrisuru::Command.new('ip')
          command.append_flag('-json') if version >= IPROUTE2_JSON_VERSION
          command.append_flag('-s', opts[:stats])

          command << 'neighbour show'

          command.append_arg('to', opts[:to])
          command.append_arg('dev', opts[:dev])
          command.append_arg('nud', opts[:nud])

          command.append_flag('unused', opts[:unused])
        when 'flush'
          command = Kanrisuru::Command.new('ip neighbour flush')
          command.append_arg('to', opts[:to])
          command.append_arg('dev', opts[:dev])
          command.append_arg('nud', opts[:nud])

          command.append_flag('unused', opts[:unused])
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          if %w[show list].include?(action)
            if version >= IPROUTE2_JSON_VERSION
              begin
                ip_neighbour_result_json(cmd.to_json)
              rescue JSON::ParserError
                ip_neighbour_result_parse(cmd.to_a)
              end
            else
              ip_neighbour_result_parse(cmd.to_a)
            end
          end
        end
      end

      def ip_maddress(action, opts)
        case action
        when 'show', 'list'
          command = Kanrisuru::Command.new('ip')

          version = ip_version
          command.append_flag('-json') if version >= IPROUTE2_JSON_VERSION
          command.append_arg('-family', opts[:family])
          command << 'maddress show'

          command.append_arg('dev', opts[:dev])
        when 'add', 'delete', 'del'
          command = Kanrisuru::Command.new('ip maddress')
          command << action

          command.append_arg('address', opts[:lladdress])
          command.append_arg('dev', opts[:dev])
        end

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          if %w[show list].include?(action)
            if version >= IPROUTE2_JSON_VERSION
              begin
                ip_maddress_result_json(cmd.to_json)
              rescue JSON::ParserError
                ip_maddress_result_parse(cmd.to_a)
              end
            else
              ip_maddress_result_parse(cmd.to_a)
            end
          end
        end
      end

      def ip_maddress_result_json(rows)
        rows.map do |row|
          maddress = IPMAddress.new(row['ifindex'], row['ifname'], [])

          entries = row['maddr'] || []
          entries.each do |entry|
            ipmaddress_entry = IPMAddressEntry.new
            entry.each do |key, value|
              ipmaddress_entry[key] = value
            end

            maddress.maddr << ipmaddress_entry
          end

          maddress
        end
      end

      def ip_maddress_result_parse(lines)
        rows = []
        current_row = nil

        lines.each.with_index do |line, _index|
          case line
          when /^\d+:\s/
            rows << current_row unless current_row.nil?

            current_row = IPMAddress.new
            parse_ip_maddr_name(current_row, line)
          when /^link/
            _, link = line.split

            entry = IPMAddressEntry.new
            entry.link = link

            current_row.maddr << entry
          when /^inet/
            values = line.split

            entry = IPMAddressEntry.new
            values.each.with_index do |value, index|
              case value
              when 'inet', 'inet6'
                entry.family = value
                entry.address = values[index + 1]
              when 'users'
                entry.users = values[index + 1].to_i
              end
            end

            current_row.maddr << entry
          end
        end

        rows << current_row
        rows
      end

      def ip_link_result_json(rows)
        result = []
        rows.each do |row|
          next if row['ifindex'].instance_of?(NilClass)

          new_row = IPLinkProperty.new(
            row['ifindex'], row['ifname'], row['flags'], row['mtu'], row['qdisc'],
            row['operstate'], row['group'], row['txqlen'], row['linkmode'],
            row['link_type'], row['address'], row['ifalias'], nil
          )

          if row.key?('stats64')
            rx = row['stats64']['rx']
            tx = row['stats64']['tx']

            new_row[:stats] = IPStats.new(
              IPStatRX.new(
                rx['bytes'], rx['packets'], rx['errors'],
                rx['dropped'], rx['over_errors'], rx['multicast']
              ),
              IPStatTX.new(
                tx['bytes'], tx['packets'], tx['errors'],
                tx['dropped'], tx['carrier_errors'], tx['collisions']
              )
            )
          end

          result << new_row
        end

        result
      end

      def ip_address_result_json(rows)
        result = []
        rows.each do |row|
          next if row['ifindex'].instance_of?(NilClass)

          new_row = IPAddressProperty.new(
            row['ifindex'], row['ifname'], row['flags'], row['mtu'], row['qdisc'],
            row['operstate'], row['group'], row['txqlen'], row['link_type'], row['address'], []
          )

          if row.key?('stats64')
            rx = row['stats64']['rx']
            tx = row['stats64']['tx']

            new_row[:stats] = IPStats.new(
              IPStatRX.new(
                rx['bytes'], rx['packets'], rx['errors'],
                rx['dropped'], rx['over_errors'], rx['multicast']
              ),
              IPStatTX.new(
                tx['bytes'], tx['packets'], tx['errors'],
                tx['dropped'], tx['carrier_errors'], tx['collisions']
              )
            )
          end

          addr_info = row['addr_info'] || []

          new_row[:address_info] = addr_info.map do |address|
            dynamic = address['dynamic'] == true || address['dynamic'] == 'true'

            IPAddressInfo.new(
              address['family'],
              IPAddr.new(address['local']),
              address['broadcast'],
              address['scope'],
              dynamic,
              address['valid_life_time'], address['preferred_life_time']
            )
          end

          result << new_row
        end

        result
      end

      def ip_neighbour_result_json(rows)
        rows.map do |row|
          neighbour = IPNeighbour.new(
            IPAddr.new(row['dst']),
            row['dev'],
            row['lladdr'],
            row['state']
          )

          if row.key?('used') || row.key?('confirmed') ||
             row.key?('refcnt') || row.key?('updated') ||
             row.key?('probes')
            neighbour.stats = IPNeighbourStats.new

            neighbour.stats.ref_count = row['refcnt']
            neighbour.stats.used = row['used']
            neighbour.stats.confirmed = row['confirmed']
            neighbour.stats.probes = row['probes']
            neighbour.stats.updated = row['updated']
          end

          neighbour
        end
      end

      def ip_neighbour_result_parse(lines)
        rows = []
        lines.each do |line|
          values = line.split

          neighbour = IPNeighbour.new(IPAddr.new(values[0]))
          neighbour.state = [values[values.length - 1]]

          if line.include?('probes') || line.include?('used') || line.include?('ref')
            neighbour.stats = IPNeighbourStats.new
          end

          values.each.with_index do |value, index|
            case value
            when 'dev'
              neighbour.device = values[index + 1]
            when 'lladdr'
              neighbour.lladdr = values[index + 1]
            when 'ref'
              neighbour.stats.ref_count = values[index + 1] ? values[index + 1].to_i : nil
            when 'used'
              used, confirmed, updated = values[index + 1].split('/')

              neighbour.stats.used = used ? used.to_i : nil
              neighbour.stats.updated = updated ? updated.to_i : nil
              neighbour.stats.confirmed = confirmed ? confirmed.to_i : nil
            when 'probes'
              neighbour.stats.probes = values[index + 1] ? values[index + 1].to_i : nil
            end
          end

          rows << neighbour
        end

        rows
      end

      def ip_address_label_result_json(rows)
        result = []

        rows.each do |row|
          new_row = IPAddressLabel.new(
            row['address'], row['prefixlen'], row['label']
          )

          result << new_row
        end

        result
      end

      def ip_route_result_json(rows)
        rows.map do |row|
          IPRoute.new(
            row['dst'],
            row['gateway'],
            row['dev'],
            row['protocol'],
            row['scope'],
            row['prefsrc'],
            row['metric'],
            row['flags']
          )
        end
      end

      def ip_route_result_parse(lines)
        rows = []

        lines.map do |line|
          values = line.split(/\s/)

          ip_route = IPRoute.new(values[0])
          ip_route.flags = []

          values.each.with_index do |value, index|
            case value
            when 'via'
              ip_route.gateway = values[index + 1]
            when 'dev'
              ip_route.device = values[index + 1]
            when 'proto'
              ip_route.protocol = values[index + 1]
            when 'src'
              ip_route.preferred_source = values[index + 1]
            when 'scope'
              ip_route.scope = values[index + 1]
            when 'flags'
              ip_route.flags = values[index + 1]
            when 'metric'
              ip_route.metric = values[index + 1]
            end
          end

          rows << ip_route
        end

        rows
      end

      def ip_rule_result_json(rows)
        rows.map do |row|
          IPRule.new(
            row['priority'],
            row['src'],
            row['table']
          )
        end
      end

      def ip_rule_result_parse(lines)
        rows = []
        lines.each do |line|
          _, priority, string = line.split(/(\d+):\s/)
          values = string.split(/\s/)

          rule = IPRule.new(priority)

          values.each.with_index do |value, index|
            case value
            when 'from'
              rule.source = values[index + 1]
            when 'lookup'
              rule.table = values[index + 1]
            end
          end

          rows << rule
        end

        rows
      end

      def ip_link_result_parse(lines)
        rows = []
        current_row = nil

        lines.each.with_index do |line, index|
          case line
          when /^\d+:\s/
            rows << current_row unless current_row.nil?

            current_row = IPLinkProperty.new
            parse_ip_row(current_row, line)
          when /^link/
            parse_link(current_row, line)
          when /^alias/
            parse_alias(current_row, line)
          when /^RX:/
            parse_rx(current_row, lines[index + 1])
          when /^TX:/
            parse_tx(current_row, lines[index + 1])
          end
        end

        rows << current_row
        rows
      end

      def ip_address_result_parse(lines)
        rows = []
        current_row = nil

        lines.each.with_index do |line, index|
          case line
          when /^\d+:\s/
            rows << current_row unless current_row.nil?

            current_row = IPAddressProperty.new
            current_row.address_info = []

            parse_ip_row(current_row, line)
          when /^link/
            parse_link(current_row, line)
          when /^inet/
            parse_address_info(current_row, line)
          when /^valid_lft/
            parse_valid(current_row, line)
          when /^RX:/
            parse_rx(current_row, lines[index + 1])
          when /^TX:/
            parse_tx(current_row, lines[index + 1])
          end
        end

        rows << current_row
        rows
      end

      def ip_address_label_result_parse(lines)
        lines.map do |line|
          _, addr, _, label = line.split(/\s/)
          address, prefix_length = addr.split(%r{/})

          IPAddressLabel.new(address, prefix_length.to_i, label)
        end
      end

      def parse_alias(row, line)
        _, alias_string = line.split('alias')
        row.alias = alias_string
      end

      def parse_ip_maddr_name(row, line)
        index = line.match(/^\d+/).to_s.to_i
        _, name = line.split(/^\d+:\s/)

        row.index = index
        row.name = name
        row.maddr = []
      end

      def parse_ip_row(row, line)
        index = line.match(/^\d+/).to_s.to_i
        _, string = line.split(/^\d+:\s/)
        name = string.match(/^\w+/).to_s
        _, string = string.split(/^\w+:\s/)
        _, flags, string = string.split(/(<.+>)\s/)

        flags = flags.gsub(/<?>?/, '')
        flags = flags.split(',')

        row.index = index
        row.name = name
        row.flags = flags

        values = string.split(/\s/)
        values.each.with_index do |_, i|
          case values[i]
          when 'mtu'
            row.mtu = values[i + 1].to_i
          when 'qdisc'
            row.qdisc = values[i + 1]
          when 'state'
            row.state = values[i + 1]
          when 'group'
            row.group = values[i + 1]
          when 'qlen'
            row.qlen = values[i + 1].to_i
          when 'mode'
            row.link_mode = values[i + 1]
          end
        end
      end

      def parse_link(row, line)
        _, string = line.split(%r{^link/})
        link_type, mac_address = string.split

        row.link_type = link_type
        row.mac_address = mac_address
      end

      def parse_address_info(row, line)
        values = line.split
        address_info = IPAddressInfo.new

        values.each.with_index do |_, index|
          case values[index]
          when 'inet', 'inet6'
            address_info.family = values[index]
            address_info.ip = IPAddr.new(values[index + 1].split('/')[0])
          when 'brd'
            address_info.broadcast = values[index + 1]
          when 'scope'
            address_info.scope = values[index + 1]
          when 'dynamic'
            address_info.dynamic = true
          end
        end

        row.address_info << address_info
      end

      def parse_valid(row, line)
        values = line.split

        values.each.with_index do |_, index|
          case values[index]
          when 'valid_lft'
            row.address_info.last.valid_life_time = values[index + 1]
          when 'preferred_lft'
            row.address_info.last.preferred_life_time = values[index + 1]
          end
        end
      end

      def parse_rx(row, line)
        values = line.split

        bytes = values[0].to_i
        packets = values[1].to_i
        errors = values[2].to_i
        dropped = values[3].to_i
        over_errors = values[4].to_i
        multicast = values[5].to_i

        row.stats = IPStats.new
        row.stats.rx = IPStatRX.new(
          bytes,
          packets,
          errors,
          dropped,
          over_errors,
          multicast
        )
      end

      def parse_tx(row, line)
        values = line.split

        bytes = values[0].to_i
        packets = values[1].to_i
        errors = values[2].to_i
        dropped = values[3].to_i
        carrier_errors = values[4].to_i
        collisions = values[5].to_i

        row.stats.tx = IPStatTX.new(
          bytes,
          packets,
          errors,
          dropped,
          carrier_errors,
          collisions
        )
      end
    end
  end
end
