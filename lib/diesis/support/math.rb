# frozen_string_literal: true

module Diesis
  module Support
    module Math
      GOLDEN_RATIO = (1 + ::Math.sqrt(5)) / 2
      SILVER_RATIO = ::Math.sqrt(2)

      def to_radian(degree)
        degree / 180 * ::Math::PI
      end

      def to_degree(radian)
        radian * 180 / ::Math::PI
      end
    end

    extend Math
  end
end
