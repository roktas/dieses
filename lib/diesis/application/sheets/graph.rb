# frozen_string_literal: true

module Diesis
  module Application
    module Sheets
      class Graph < Sheet
        sheet :graph, 'Graph worksheet'

        include Mixins::Lines
        include Mixins::Squares

        variate unit: [5, 7, 10], square: [6, 8] do
          self.name = "#{unit}#{square}"
          self.desc = "#{square} squares with #{unit} mm unit"
        end

        hline :hline, style: Style.(stroke: 'blue', 'stroke-width': '0.1')
        vline :vline, style: Style.(stroke: 'blue', 'stroke-width': '0.1')

        def call
          lines   unit: param.unit, multiple: param.square
          squares unit: param.unit, square: param.square
        end
      end
    end
  end
end
