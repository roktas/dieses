# frozen_string_literal: true

module Diesis
  module Application
    module Sheets
      class Ruled < Sheet
        sheet :ruled, 'Ruled worksheet'

        variate unit: [5, 7, 10] do
          self.name = unit.to_s
          self.desc = "#{unit} mm unit"
        end

        def call
          draw unit: param.unit do
            repeat do
              hline :hline, style: Style.(stroke: 'blue', 'stroke-width': '0.1')
              down
            end

            repeat do
              vline :vline, style: Style.(stroke: 'blue', 'stroke-width': '0.1')
              right
            end
          end
        end
      end
    end
  end
end
