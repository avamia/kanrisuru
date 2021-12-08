require_relative 'commands/cat'
require_relative 'commands/echo'
require_relative 'commands/head'
require_relative 'commands/read_file_chunk'
require_relative 'commands/sed'
require_relative 'commands/tail'

module Kanrisuru
  module Core
    module Stream
      private
      def append_file(command, opts)
        return unless Kanrisuru::Util.present?(opts[:new_file])

        case opts[:mode]
        when 'append'
          command << ">> #{opts[:new_file]}"
        when 'write'
          command << "> #{opts[:new_file]}"
        end
      end
    end
  end
end
