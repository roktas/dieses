# frozen_string_literal: true

module Dieses
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

        hline :hline
        vline :vline

        def call
          lines   multiple: param.square
          squares multiple: param.square
        end
      end
    end
  end
end
