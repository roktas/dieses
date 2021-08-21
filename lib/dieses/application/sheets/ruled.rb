# frozen_string_literal: true

module Dieses
  module Application
    module Sheets
      class Ruled < Sheet
        sheet :ruled, 'Ruled worksheet'

        include Mixins::Lines

        variate unit: [5, 7, 10] do
          self.name = unit.to_s
          self.desc = "#{unit} mm unit"
        end

        hline :hline
        vline :vline

        def call
          lines
        end
      end
    end
  end
end
