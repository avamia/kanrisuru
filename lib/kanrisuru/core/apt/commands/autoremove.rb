# frozen_string_literal: true

module Kanrisuru
  module Core
    module Apt
      def apt_autoremove(_opts)
        command = Kanrisuru::Command.new('apt-get autoremove')
        command.append_flag('-y')

        execute_shell(command)
        Kanrisuru::Result.new(command)
      end
    end
  end
end
