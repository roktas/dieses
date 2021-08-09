# frozen_string_literal: true

require 'delegate'

module Dieses
  module Application
    class Canvas < DelegateClass(Geometry::Rect)
      TEMPLATE = <<~XML
        <?xml version="1.0" standalone="no"?>
        <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
        <svg xmlns="http://www.w3.org/2000/svg" width="%{width}mm" height="%{height}mm" viewBox="0 0 %{width} %{height}" %{header}>
        %{style}
          <g id="sheet">
        %{content}
          </g>
        </svg>
      XML

      attr_reader :elements, :paper

      def initialize(paper = Paper.a4)
        super(paper.inner)

        @paper    = paper
        @elements = Set.new
      end

      def to_h
        @paper.to_h
      end

      def <<(items)
        [*items].each do |item|
          case item
          when Array             then item.each { |element| elements << element }
          when Geometry::Element then elements << item
          else                        raise Error, 'Item must be an Array or Element'
          end
        end
      end

      def render(header: EMPTY_STRING, style: EMPTY_STRING)
        # We avoid prettifying XML through REXML which is pretty slow, at the cost of some ugly hacks.
        format(TEMPLATE, **to_h,
               content: Geometry.to_svg(elements, paper, prefix: ' ' * 4),
               header:  header,
               style:   style.empty? ? '' : format('<style>%{style}</style>', style: style))
      end
    end
  end
end
