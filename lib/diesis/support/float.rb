# frozen_string_literal: true

module Diesis
  module Support
    module Float
      @precision = PRECISION = 5

      class << self
        attr_accessor :precision
      end

      def round(float, precision)
        precision ? float.round(precision) : float
      end

      def approx(float, precision = nil)
        float.round(precision || Float.precision)
      end

      def almost_equal(left, right, precision: Float.precision)
        round(left, precision) == round(right, precision)
      end

      def almost_less_or_equal(left, right, precision: Float.precision)
        round(left, precision) <= round(right, precision)
      end

      def almost_greater_or_equal(left, right, precision: Float.precision)
        round(left, precision) >= round(right, precision)
      end

      def almost_less_than(left, right, precision: Float.precision)
        round(left, precision) < round(right, precision)
      end

      def almost_greater_than(left, right, precision: Float.precision)
        round(left, precision) > round(right, precision)
      end
    end

    extend Float
  end
end
