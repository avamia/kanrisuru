# frozen_string_literal: true

module Kanrisuru
  module Core
    module Group
      def group?(group)
        result = get_gid(group)
        return false if result.failure?

        Kanrisuru::Util.present?(result.data) && result.data.instance_of?(Integer)
      end
    end
  end
end
