# frozen_string_literal: true

module Kanrisuru
  module Core
    module User
      def user?(user)
        result = get_uid(user)
        return false if result.failure?

        Kanrisuru::Util.present?(result.data) && result.data.instance_of?(Integer)
      end
    end
  end
end
