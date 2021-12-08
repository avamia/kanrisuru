module Kanrisuru::Core::IP
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
      command.append_flag('-json') if version >= Kanrisuru::Core::IP::IPROUTE2_JSON_VERSION
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
      Parser::Neighbour.parse(cmd, action, version)
    end
  end
end
