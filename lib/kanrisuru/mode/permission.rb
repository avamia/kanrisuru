# frozen_string_literal: true

module Kanrisuru
  class Mode
    class Permission
      attr_reader :symbolic

      def initialize(numeric, symbolic)
        @numeric = numeric
        @symbolic = symbolic

        update_symbolic_rwx
      end

      def to_i
        numeric.to_i
      end

      def to_s
        symbolic
      end

      def numeric
        @numeric.to_s
      end

      def all?
        read? && write? && execute?
      end

      def symbolic=(symbolic)
        @symbolic = symbolic

        update_symbolic_rwx
        update_numeric
      end

      def numeric=(numeric)
        @numeric = numeric

        update_numeric_rwx
        update_symbolic
      end

      def read=(boolean)
        @readable = boolean

        update_numeric
        update_symbolic
      end

      def write=(boolean)
        @writeable = boolean

        update_numeric
        update_symbolic
      end

      def execute=(boolean)
        @executable = boolean

        update_numeric
        update_symbolic
      end

      def read?
        @readable
      end

      def write?
        @writeable
      end

      def execute?
        @executable
      end

      private

      def update_symbolic_rwx
        @readable   = @symbolic.include?('r')
        @writeable  = @symbolic.include?('w')
        @executable = @symbolic.include?('x')
      end

      def update_numeric_rwx
        mode = @numeric.to_i(8)

        @readable   = ((mode >> 2) & 0b001) == 1
        @writeable  = ((mode >> 1) & 0b001) == 1
        @executable = ((mode >> 0) & 0b001) == 1
      end

      def update_numeric
        @numeric = (((read? ? 1 : 0) << 2) + ((write? ? 1 : 0) << 1) + (execute? ? 1 : 0)).to_s
      end

      def update_symbolic
        @symbolic = "#{read? ? 'r' : '-'}#{write? ? 'w' : '-'}#{execute? ? 'x' : '-'}"
      end
    end
  end
end
