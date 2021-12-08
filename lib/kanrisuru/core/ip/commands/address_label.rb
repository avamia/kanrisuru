module Kanrisuru::Core::IP
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
      Parser::AddressLabel.parse(cmd, action, version)
    end
  end
end
