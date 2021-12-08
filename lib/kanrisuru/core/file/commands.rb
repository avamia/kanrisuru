# frozen_string_literal: true

require_relative 'commands/chmod'
require_relative 'commands/chown'
require_relative 'commands/copy'
require_relative 'commands/link'
require_relative 'commands/mkdir'
require_relative 'commands/move'
require_relative 'commands/rm'
require_relative 'commands/symlink'
require_relative 'commands/touch'
require_relative 'commands/unlink'
require_relative 'commands/wc'

module Kanrisuru
  module Core
    module File
      private

      def backup_control_valid?(backup)
        opts = %w[
          none off numbered t existing nil simple never
        ]

        opts.include?(backup)
      end
    end
  end
end
