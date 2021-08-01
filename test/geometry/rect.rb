# frozen_string_literal: true

require_relative 'test_helper'

module Diesis
  module Geometry
    class RectTest < Minitest::Test
      def test_rect_predicate_inside
        rect = Rect.new(3, 4)
        assert rect.inside?(Point.new(1, 1))
      end

      def test_rect_predicate_onto
        rect = Rect.new(3, 4)
        assert rect.onto?(Point.new(3, 0))
      end

      def test_rect_predicate_outside
        rect = Rect.new(3, 4)
        assert rect.outside?(Point.new(5, 0))
      end
    end
  end
end
