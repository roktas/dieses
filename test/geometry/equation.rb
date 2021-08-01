# frozen_string_literal: true

require_relative 'test_helper'

module Diesis
  module Geometry
    class EquationTest < Minitest::Test
      def test_slant
        equ = Equation.slant(slope: 4.0 / 3.0, intercept: -4)
        assert_in_delta(-4.0, equ.y(0))
      end

      def test_steep
        equ = Equation.steep(1.0)
        assert_in_delta(1.0, equ.x(1))
        assert_equal(Float::INFINITY, equ.y(1))
      end

      def test_slant_predicate_left
        equ = Equation.slant_from_direction(point: Point.new(0, 0), angle: 53.13)
        assert equ.left?(Diesis::Point.new(-5, 0))
      end

      def test_slant_predicate_onto
        equ = Equation.slant_from_direction(point: Point.new(0, 0), angle: 53.13)
        assert equ.onto?(Diesis::Point.new(0, 0))
      end

      def test_slant_predicate_right
        equ = Equation.slant_from_direction(point: Point.new(0, 0), angle: 53.13)
        assert equ.right?(Diesis::Point.new(5, 0))
      end

      def test_steep_predicate_left
        equ = Equation.steep(5.0)
        assert equ.left?(Diesis::Point.new(-5, 0))
      end

      def test_steep_predicate_onto
        equ = Equation.steep(5.0)
        assert equ.onto?(Diesis::Point.new(5, 0))
        assert equ.onto?(Diesis::Point.new(5, -1))
      end

      def test_steep_predicate_right
        equ = Equation.steep(5.0)
        assert equ.right?(Diesis::Point.new(10, 0))
      end

      def test_intersect_steep_slant
        equ = Equation.steep(5.0)
        line = Line.new(Point.new(-2, -1), Point.new(0, 1))
        point = equ.intersect(Equation.from_line(line)).approx
        assert_equal(Point.new(5, 6), point)
      end

      def test_intersect_slant_slant
        equ = Equation.slant(slope: 4.0 / 3.0, intercept: -4)
        line = Line.new(Point.new(-2, -1), Point.new(0, 1))
        point = equ.intersect(Equation.from_line(line)).approx
        assert_equal(Point.new(15, 16), point)
      end

      def test_intersect_steep_steep
        equ = Equation.steep(5.0)
        point = equ.intersect(Equation.steep(1.0))
        assert_equal(Point.new(Float::INFINITY, Float::INFINITY), point)
      end
    end
  end
end
