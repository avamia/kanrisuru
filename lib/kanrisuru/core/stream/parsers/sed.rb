module Kanrisuru::Core::Stream
  module Parser
    class Sed
      def self.perform(command)
        return unless Kanrisuru::Util.present?(opts[:new_file])
        
        cmd.to_a.join("\n")
      end
    end
  end
end