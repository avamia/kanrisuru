# frozen_string_literal: true

module Kanrisuru
  module Core
    module Apt
      def apt_search(opts)
        command = Kanrisuru::Command.new('apt search')
        command << opts[:query]

        execute_shell(command)

        Kanrisuru::Result.new(command) do |cmd|
          Parser::Search.parse(cmd)
        end
      end
    end
  end
end
