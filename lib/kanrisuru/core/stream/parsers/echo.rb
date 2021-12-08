module Kanrisuru::Core::Stream
  module Parser
    class Echo
      def self.parse(command, opts)
        return unless Kanrisuru::Util.present?(opts[:new_file])
        cmd.to_s
      end
    end
  end
end
