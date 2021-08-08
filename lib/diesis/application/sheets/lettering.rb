# frozen_string_literal: true

module Diesis
  module Application
    module Sheets
      class Lettering < Sheet
        sheet :lettering, 'Lettering worksheet'

        include Mixins::Lines
        include Mixins::Squares

        variate unit: [5], square: [6, 8] do
          self.name = "#{unit}#{square}"
          self.desc = "#{square} squares with #{unit} mm unit"
        end

        hline :hline, style: Style.(stroke: 'blue', 'stroke-width': '0.1')
        vline :vline, style: Style.(stroke: 'blue', 'stroke-width': '0.1')

        cline :slant,      angle: 52.0, style: Style.(stroke: 'blue', 'stroke-width': 0.1)
        cline :connective, angle: 30.0, style: Style.(stroke: 'blue', 'stroke-width': 0.07, 'stroke-dasharray': '2, 2')

        def call
          lines   multiple: param.square
          squares square: param.square
        end
      end
    end
  end
end
