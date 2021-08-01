# frozen_string_literal: true

require 'forwardable'

module Diesis
  module Geometry
    class Rect < Element
      Side   = Struct.new(*%i[top right bottom left], keyword_init: true)                       # in CSS margin order
      Corner = Struct.new(*%i[bottom_left top_left top_right bottom_right], keyword_init: true) # cw from position

      private_constant :Side
      private_constant :Corner

      extend Forwardable

      def_delegators :@side,   *Side.members
      def_delegators :@corner, *Corner.members

      attr_reader :width, :height, :position

      def initialize(width, height, position: Point.origin)
        @width    = width.to_f
        @height   = height.to_f
        @position = Point.cast(position)
        @corner   = calculate_corner
        @side     = calculate_side

        super()
      end

      def translate(x: 0, y: 0)
        self.class.new width, height, position: position.translate(x: x, y: y)
      end

      def shrink(width: 0, height: 0)
        self.class.new self.width - width, self.height - height, position: position
      end

      module Align
        module_function

        def center(this, that)
          Point.new(this.position.x + (this.width  - that.width)  / 2,
                    this.position.y + (this.height - that.height) / 2)
        end

        def left(this, that)
          Point.new(this.position.x, that.position.y)
        end

        def right(this, that)
          Point.new(this.position.x + (this.width - that.width), that.position.y)
        end

        def top(this, that)
          Point.new(that.position.x, this.position.y + (this.height - that.height))
        end

        def bottom(this, that)
          Point.new(that.position.x, this.position.y)
        end
      end

      private_constant :Align

      def align(other, alignment = :center)
        raise ArgumentError, "No such alignment type: #{alignment}" unless Align.respond_to? alignment

        self.class.new other.width, other.height, position: Align.public_send(alignment, self, other).approx
      end

      Orientation = Support::Enum.of(:portrait, :landscape)

      def orientation
        value = if Support.almost_greater_than(width, height)
                  :landscape
                else
                  :portrait
                end
        Orientation.(value)
      end

      def orient(new_orientation)
        new_orientation = Orientation.(new_orientation)
        return self if orientation == new_orientation

        self.class.new height, width, position: position
      end

      module Predicate
        def inside?(point)
          onto?(point) || (
            left.right?(point) && right.left?(point) && top.left?(point) && bottom.right?(point)
          )
        end

        def outside?(point)
          !inside?(point)
        end

        def onto?(point)
          left.onto?(point) || right.onto?(point) || top.onto?(point) || bottom.onto?(point)
        end

        def cover?(element)
          bbox = element.bbox
          inside?(bbox.minimum) && inside?(bbox.maximum)
        end
      end

      include Predicate

      def intersect(equation, precision: nil)
        points = Side.members
          .map { |line| public_send(line).intersect(equation).approx(precision) }
          .uniq
          .select { |intersect| onto?(intersect) }
          .sort

        return if points.empty?

        raise "Unexpected number of intersection points: #{points.size}" unless points.size <= 2

        Line.new((starting = points.shift), (points.shift || starting))
      end

      def angle
        Math.atan(height / width)
      end

      def bbox
        BoundingBox.new(@corner.values.min, @corner.values.max)
      end

      def to_s
        repr = "R(#{width}, #{height})"
        return repr if position == Point.origin

        "#{repr}@#{position}"
      end

      def to_h
        { width: width, height: height, **position.to_h }
      end

      # codebeat:disable[ABC]
      def to_svgf
        <<~SVG
          <rect width="#{Support.approx(width)}" height="#{Support.approx(height)}" x="#{Support.approx(position.x)}" y="#{Support.approx(position.y)}" %{attributes}/>
        SVG
      end

      private

      def calculate_corner
        Corner.new(top_left:     position,
                   top_right:    Point.new(position.x + width, position.y),
                   bottom_right: Point.new(position.x + width, position.y + height),
                   bottom_left:  Point.new(position.x,         position.y + height))
      end

      def calculate_side
        Side.new(top:    Line.new(@corner.top_left,     @corner.top_right),
                 right:  Line.new(@corner.top_right,    @corner.bottom_right),
                 bottom: Line.new(@corner.bottom_left,  @corner.bottom_right),
                 left:   Line.new(@corner.top_left,     @corner.bottom_left))
      end
      # codebeat:enable[ABC]
    end
  end
end
