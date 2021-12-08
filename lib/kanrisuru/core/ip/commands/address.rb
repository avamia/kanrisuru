module Kanrisuru::Core::IP
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
      Parser::Address.parse(cmd, action, version)
    end
  end
end
