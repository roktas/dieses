# frozen_string_literal: true

module Diesis
  module Application
    module Sheets
      class Graph < Sheet
        sheet :graph, 'Graph worksheet'

        variate unit: [5, 7, 10], square: [8] do
          self.name = "#{unit}#{square}"
          self.desc = "#{square} squares with #{unit} mm unit"
        end

        def call # rubocop:disable Layout/MethodLength
          param = self.param

          draw unit: param.unit, multiple: param.square do
            repeat do
              hline :hline, style: Style.(stroke: 'blue', 'stroke-width': '0.1')
              down
            end

            repeat do
              vline :vline, style: Style.(stroke: 'blue', 'stroke-width': '0.1')
              right
            end

            repeat do
              repeat do
                rect :rect, width: param.square, height: param.square, style: Style.(stroke: 'blue', 'stroke-width': '0.4', fill: 'none') # rubocop:disable Metrics/LineLength
                right param.square
              end
              down param.square
            end
          end
        end
      end
    end
  end
end
