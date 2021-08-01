# frozen_string_literal: true

require_relative 'equation/slant'
require_relative 'equation/steep'

module Diesis
  module Geometry
    module Equation
      module_function

      def from_line(line)
        starting, ending = line.starting, line.ending

        if (c = starting.x) == ending.x
          vertical(c)
        elsif (c = starting.y) == ending.y
          horizontal(c)
        else
          slope     = (ending.y - starting.y) / (ending.x - starting.x)
          intercept = starting.y - slope * starting.x

          slant(slope: slope, intercept: intercept)
        end
      end

      def slant(slope:, intercept:)
        Slant.new slope: slope, intercept: intercept
      end

      def slant_from_direction(point:, angle:)
        return horizontal(point.y) if (angle % 180).zero?
        return vertical(point.x)   if (angle % 90).zero?

        slope     = Math.tan(Support.to_radian(angle.to_f))
        intercept = point.y - slope * point.x

        slant(slope: slope, intercept: intercept)
      end

      def steep(c)
        Steep.new c
      end

      class << self
        alias vertical steep
      end

      def horizontal(c)
        slant(slope: 0.0, intercept: c)
      end

      def intersect(u, v)
        u.intersect(v)
      end
    end
  end
end
