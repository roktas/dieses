# frozen_string_literal: true

module Diesis
  module Application
    module Sheets
      class Ruled < Sheet
        sheet :ruled, 'Ruled worksheet'

        include Mixins::Lines

        variate unit: [5, 7, 10] do
          self.name = unit.to_s
          self.desc = "#{unit} mm unit"
        end

        hline :hline, style: Style.(stroke: 'blue', 'stroke-width': '0.1')
        vline :vline, style: Style.(stroke: 'blue', 'stroke-width': '0.1')

        def call
          lines unit: param.unit
        end
      end
    end
  end
end
