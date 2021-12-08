# frozen_string_literal: true

module Kanrisuru
  module Core
    module Apt
      def apt_clean(_opts)
        command = Kanrisuru::Command.new('apt-get clean')
        execute_shell(command)
        Kanrisuru::Result.new(command)
      end
    end
  end
end
