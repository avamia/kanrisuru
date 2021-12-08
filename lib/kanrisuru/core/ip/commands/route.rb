module Kanrisuru::Core::IP
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
      Parser::Route.parse(cmd, action, version)
    end
  end
end
