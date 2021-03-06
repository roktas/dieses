# frozen_string_literal: true

require 'delegate'

module Dieses
  module Application
    class Canvas < DelegateClass(Geometry::Rect)
      TEMPLATE = <<~XML
        <?xml version="1.0" standalone="no"?>
        <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
        <svg xmlns="http://www.w3.org/2000/svg" width="%{width}mm" height="%{height}mm" viewBox="0 0 %{width} %{height}" shape-rendering="geometricPrecision" %{header}>
          <style>
            svg         { stroke:           %8{color}; }
            svg         { stroke-width:     %8{medium}; }
            .altcolor   { stroke:           %8{altcolor}; }
            .extrafine  { stroke-width:     %8{extrafine}; }
            .fine       { stroke-width:     %8{fine}; }
            .medium     { stroke-width:     %8{medium}; }
            .broad      { stroke-width:     %8{broad}; }
            .extrabroad { stroke-width:     %8{extrabroad}; }
            .dashed     { stroke-dasharray: %8{dashed}; }
          </style>
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

      def <<(items)
        [*items].each do |item|
          case item
          when Array             then item.each { |element| elements << element }
          when Geometry::Element then elements << item
          else                        raise Error, 'Item must be an Array or Element'
          end
        end
      end

      def render(header: EMPTY_STRING, variables: EMPTY_HASH)
        # We avoid prettifying XML through REXML which is pretty slow, at the cost of a somewhat hacky code.
        format(TEMPLATE, **variables(**variables),
               content: Geometry.to_svg(elements, paper, prefix: ' ' * 4),
               header:  header)
      end

      private

      DEFAULT_COLOR     = '#ed008c'
      DEFAULT_ALTCOLOR  = 'blue'
      DEFAULT_LINEWIDTH = 0.04
      DEFAULT_DASHES    = [2, 2].freeze

      def variables(**kwargs) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/PerceivedComplexity
        paper.to_h.merge(kwargs).tap do |variables|
          linewidth = (variables[:linewidth] || variables[:medium] || DEFAULT_LINEWIDTH).to_f

          variables[:color]      ||= DEFAULT_COLOR
          variables[:altcolor]   ||= DEFAULT_ALTCOLOR
          variables[:medium]     ||= linewidth.to_s
          variables[:extrafine]  ||= (linewidth / 4.0).to_s
          variables[:fine]       ||= (linewidth / 2.0).to_s
          variables[:broad]      ||= (linewidth * 2.0).to_s
          variables[:extrabroad] ||= (linewidth * 4.0).to_s
          variables[:dashed]     ||= DEFAULT_DASHES.map(&:to_s).join(' ')
        end
      end
    end
  end
end
