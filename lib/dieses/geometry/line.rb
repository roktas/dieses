# frozen_string_literal: true

require 'forwardable'

module Dieses
  module Geometry
    class Line < Element
      extend Forwardable

      def_delegators :@equation, :left?, :right?, :intersect

      attr_reader :starting, :ending, :equation

      def initialize(starting, ending)
        @starting, @ending = Point.cast(starting), Point.cast(ending)
        @equation = Equation.from_line(self)

        super()
      end

      def translate(x: nil, y: nil)
        starting, ending = [self.starting, self.ending].map { |point| point.translate(x: x, y: y) }
        self.class.new starting, ending
      end

      def duplicate(x: nil, y: nil, count: 1)
        lines, line = [], self

        count.times do
          lines << line
          line = line.translate(x: x, y: y)
        end

        [lines, line]
      end

      def duplicates(x: nil, y: nil, count: 1)
        lines, = duplicate(x: x, y: y, count: count)
        lines
      end

      def onto?(point)
        equation.onto?(point) && point >= starting && point <= ending
      end

      def to_svgf
        x1, y1, x2, y2 = [*starting.to_a, *ending.to_a].map { |value| Support.approx(value) }

        <<~SVG
          <line x1="#{x1}" y1="#{y1}" x2="#{x2}" y2="#{y2}" %{attributes}/>
        SVG
      end

      def to_s
        "L(#{starting}, #{ending})"
      end

      def to_h
        { starting: starting, ending: ending }
      end

      def bbox
        BoundingBox.new([starting, ending].min, [starting, ending].max)
      end
    end
  end
end
