# frozen_string_literal: true

module Dieses
  module Geometry
    module Equation
      class Slant
        attr_reader :slope, :intercept

        def initialize(slope:, intercept:)
          @slope, @intercept = slope.to_f, intercept.to_f
          freeze
        end

        def x(y)
          (y - intercept) / slope
        end

        def y(x)
          (slope * x) + intercept
        end

        # When distance given, y = m * x + n (m, n positive) equation moves to the right (x increases, y decreases)
        def translate(distance = nil, x: nil, y: nil)
          dx, dy = 0, 0

          intercept = self.intercept

          dx, dy = distance * Math.cos(angle_in_radian), -distance * Math.sin(angle_in_radian) if distance

          dx += x if x
          dy += y if y

          intercept -= slope * dx
          intercept += dy

          self.class.new slope: slope, intercept: intercept
        end

        def angle_in_radian
          Math.atan(slope)
        end

        def intersect(other)
          case other
          when Slant
            x = (other.intercept - intercept) / (slope - other.slope)
            y = (slope * x) + intercept
          when Steep
            x = other.x
            y = y(x)
          end

          Point.new(x, y)
        end

        def left?(point, precision: Support::Float.precision)
          Support.almost_greater_than(point.y, y(point.x), precision: precision)
        end

        def right?(point, precision: Support::Float.precision)
          Support.almost_less_than(point.y, y(point.x), precision: precision)
        end

        def onto?(point, precision: Support::Float.precision)
          Support.almost_equal(point.y, y(point.x), precision: precision)
        end

        def eql?(other)
          self.class == other.class && to_h == other.to_h
        end

        alias == eql?

        def hash
          self.class.hash ^ to_h.hash
        end

        def to_h
          { slope: scope, intercept: intercept }
        end

        def to_s
          "E(y = #{slope} * x + #{intercept})"
        end
      end
    end
  end
end
