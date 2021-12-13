# frozen_string_literal: true

require_relative 'commands/address'
require_relative 'commands/address_label'
require_relative 'commands/link_type_opts'
require_relative 'commands/link_set_opts'
require_relative 'commands/link'
require_relative 'commands/maddress'
require_relative 'commands/neighbour'
require_relative 'commands/route'
require_relative 'commands/rule'

module Kanrisuru
  module Core
    module IP
      def ip_version
        command = Kanrisuru::Command.new('ip -V')
        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Version.parse(cmd)
        end
      end
    end
  end
end
