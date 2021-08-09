# frozen_string_literal: true

module Dieses
  module Geometry
    class Point
      include Comparable

      attr_reader :x, :y, :hash

      def initialize(x, y)
        @x, @y = x.to_f, y.to_f
        @hash  = Point.hash ^ to_a.hash

        freeze
      end

      def translate(x: nil, y: nil)
        self.class.new(self.x + (x || 0), self.y + (y || 0))
      end

      def distance(other = nil)
        self.class.distance(self, other)
      end

      def approx(precision = nil)
        self.class.new Support.approx(x, precision), Support.approx(y, precision)
      end

      def <=>(other)
        return unless other.is_a? Point

        to_a <=> other.to_a
      end

      def eql?(other)
        return false unless other.is_a? Point

        to_a == other.to_a
      end

      alias == eql?

      def to_s
        "P(#{x}, #{y})"
      end

      def to_a
        [x, y]
      end

      def to_h
        { x: x, y: y }
      end

      class << self
        def call(*args)
          new(*args)
        end

        def origin
          new 0.0, 0.0
        end

        def distance(starting, ending)
          ending ||= origin
          Math.sqrt((ending.x - starting.x)**2 + (starting.y - ending.y)**2)
        end

        def cast(point)
          Point.new(point.x, point.y)
        end
      end

      class Mutable < Point
        attr_writer :x, :y

        def initialize(x, y) # rubocop:disable Lint/MissingSuper
          @x, @y = x.to_f, y.to_f
        end

        def hash
          (@hash ||= self.class.hash) ^ to_a.hash
        end

        def translate!(x: nil, y: nil)
          tap do
            self.x += (x || 0)
            self.y += (y || 0)
          end
        end

        def self.cast(immutable_point)
          Mutable.new(immutable_point.x, immutable_point.y)
        end
      end
    end
  end
end
