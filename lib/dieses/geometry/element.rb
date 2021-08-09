# frozen_string_literal: true

module Dieses
  module Geometry
    class Element
      BoundingBox = Struct.new :minimum, :maximum

      attr_reader :attributes, :hash

      def initialize
        @attributes = {}
        @hash       = self.class.hash ^ to_h.hash
        freeze
      end

      def attr(**kwargs)
        tap do
          kwargs.each { |key, value| attributes[key.to_sym] = value }
        end
      end

      def classify(*tags, **kwargs)
        existing_class = attributes[:class] || Set.new
        attr(**kwargs, tags: existing_class.add(tags))
      end

      def to_svg
        format to_svgf, attributes: Support.kwargs_to_s(**attributes)
      end

      def eql?(other)
        return false unless other.is_a? self.class

        to_h == other.to_h
      end

      alias == eql?
    end

    class << self
      def centered(elements, rect)
        bbox = bounding_box_of(*elements)

        x = (rect.width  - bbox.maximum.x + bbox.minimum.x) / 2
        y = (rect.height - bbox.maximum.y + bbox.minimum.y) / 2

        elements.map { |element| element.translate(x: x, y: y).attr(**element.attributes.dup) }
      end

      def to_svg(elements, rect = Undefined, prefix: EMPTY_STRING)
        (Undefined.equal?(rect) ? elements : centered(elements, rect)).map do |element|
          "#{prefix}#{element.to_svg}"
        end.join.chomp
      end

      def bounding_box_of(*elements)
        bboxes = elements.map(&:bbox)

        minimum = bboxes.map(&:minimum).min
        maximum = bboxes.map(&:maximum).max

        Element::BoundingBox.new minimum, maximum
      end
    end
  end
end
