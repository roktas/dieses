# frozen_string_literal: true

module Diesis
  module Geometry
    module Equation
      class Steep
        def initialize(c)
          @x = c
        end

        def y(_ = nil)
          Float::INFINITY
        end

        def x(_ = nil)
          @x
        end

        # rubocop:disable Lint/UnusedMethodArgument
        def translate(distance = nil, x: nil, y: nil)
          self.class.new self.x + (distance || 0.0) + (x || 0.0)
        end
        # rubocop:enable Lint/UnusedMethodArgument

        def intersect(other)
          case other
          when Slant
            x = self.x
            y = other.y(x)
          when Steep
            x = Float::INFINITY
            y = Float::INFINITY
          end

          Point.new(x, y)
        end

        def left?(point, precision: Support::Float.precision)
          Support.almost_less_than(point.x, x(point.y), precision: precision)
        end

        def right?(point, precision: Support::Float.precision)
          Support.almost_greater_than(point.x, x(point.y), precision: precision)
        end

        def onto?(point, precision: Support::Float.precision)
          Support.almost_equal(point.x, x(point.y), precision: precision)
        end

        def eql?(other)
          self.class == other.class && x == other.x
        end

        alias == eql?

        def hash
          self.class.hash ^ to_h.hash
        end

        def to_h
          { x: x }
        end

        def to_s
          "E(x = #{c})"
        end
      end
    end
  end
end
