# frozen_string_literal: true

module Kanrisuru
  module Remote
    class Memory
      def initialize(host)
        @host = host
      end

      method_names = %w[total free swap swap_free]
      method_names.each do |method_name|
        define_method(method_name.to_s) do |metric = :kb|
          value = @host.free(method_name).to_i
          metric == :kb ? value : Kanrisuru::Util::Bits.convert_from_kb(value, metric)
        end
      end
    end
  end
end
