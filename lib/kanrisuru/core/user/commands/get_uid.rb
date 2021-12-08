# frozen_string_literal: true

module Kanrisuru
  module Core
    module User
      def get_uid(user)
        command = Kanrisuru::Command.new("id -u #{user}")

        execute(command)

        Kanrisuru::Result.new(command, &:to_i)
      end
    end
  end
end
