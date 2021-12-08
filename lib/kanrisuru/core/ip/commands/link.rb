module Kanrisuru::Core::IP
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
      Parser::Link.parse(cmd, action, version)
    end
  end
end
