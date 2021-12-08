# frozen_string_literal: true

module Kanrisuru
  module Core
    module Apt
      def apt_upgrade(_opts)
        command = Kanrisuru::Command.new('apt-get upgrade')
        command.append_flag('-y')
        execute_shell(command)
        Kanrisuru::Result.new(command)
      end
    end
  end
end
