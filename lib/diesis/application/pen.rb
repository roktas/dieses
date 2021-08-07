# frozen_string_literal: true

module Diesis
  module Application
    class Pen
      attr_reader :canvas

      def initialize(canvas)
        @canvas = canvas
      end

      def draw(unit:, multiple: nil, &block)
        Draw.(self, Ruler.(unit, multiple), &block)
      end

      Ruler = Struct.new :unit, :multiple do
        def self.call(unit, multiple = nil)
          new unit, (multiple || 1)
        end

        def major
          @major ||= multiple * unit
        end

        def even(length)
          major * (length / major).to_i
        end

        def measure(n)
          n * unit
        end
      end

      class Draw
        extend Forwardable

        def_delegators :@pen, :canvas
        def_delegators :@buffer, :<<
        def_delegators :@ruler, :unit, :multiple

        def self.call(pen, ruler, &block)
          Draw.new(pen, ruler).(&block)
        end

        def initialize(pen, ruler, pos: Undefined)
          @pen    = pen
          @pos    = Undefined.default(pos, Geometry::Point::Mutable.cast(canvas.position))
          @ruler  = ruler
          @buffer = Set.new
        end

        def repeat(count = nil, &block)
          self.class.new(pen, ruler, pos: pos.dup).instance_exec do
            1.step(count) do
              prev = pos.dup
              instance_exec(&block)
              put

              break if pos == prev || perfect.outside?(pos)
            rescue Offsite
              break
            end
          end
        end

        def call(&block)
          instance_exec(&block)
          put
        end

        private

        attr_reader :pen, :pos, :ruler, :buffer

        def perfect
          @perfect ||= Geometry::Rect.new(ruler.even(canvas.width), ruler.even(canvas.height))
        end

        Offsite = Class.new StopIteration

        module Elements
          def hline(tag = Undefined, length: Undefined, style: Undefined)
            length = Undefined.equal?(length) ? perfect.width : ruler.measure(length)
            add Geometry::Line.new(pos, pos.translate(x: length)), tag, style
          end

          def vline(tag = Undefined, length: Undefined, style: Undefined)
            length = Undefined.equal?(length) ? perfect.height : ruler.measure(length)
            add Geometry::Line.new(pos, pos.translate(y: length)), tag, style
          end

          # FIXME: Genelleştir
          def cline(tag = Undefined, angle:, style: Undefined)
            add perfect.intersect(Geometry::Equation.slant_from_direction(point: pos, angle: -angle)), tag, style
          end

          def rect(tag = Undefined, width:, height:, style: Undefined)
            width, height = ruler.measure(width), ruler.measure(height)
            add Geometry::Rect.new(width, height, position: pos), tag, style
          end

          def square(tag = Undefined, width:, style: Undefined)
            rect(tag, width: width, height: width, style: style)
          end

          private

          BASE_STYLE = { stroke: 'black', 'stroke-width': '0.1' }.freeze

          def add(element, tag, style)
            raise Offsite unless element && perfect.cover?(element)

            tag = Undefined.default(tag, caller_locations(1, 1).first.label.to_sym)

            element.tap do
              buffer << element.classify(tag, **BASE_STYLE.merge(Undefined.default(style, EMPTY_HASH).to_h))
            end
          end

          def put
            canvas.tap do
              buffer.each { |element| canvas << element }
            end
          end
        end

        module Movements
          def move(x: Undefined, y: Undefined)
            tap do
              pos.translate!(x: x * ruler.unit) unless Undefined.equal?(x)
              pos.translate!(y: y * ruler.unit) unless Undefined.equal?(y)
            end
          end

          def up(y = 1)
            move y: -y
          end

          def down(y = 1)
            move y: y
          end

          def left(x = 1)
            move x: -x
          end

          def right(x = 1)
            move x: x
          end

          def cross(distance = 1, angle: Undefined)
            radian = Undefined.equal?(angle) ? perfect.angle : Support.to_radian(angle)
            move x: distance * Math.cos(radian), y: distance * Math.sin(radian)
          end
        end

        include Elements
        include Movements
      end
    end
  end
end
