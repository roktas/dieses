# frozen_string_literal: true

module Dieses
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

        hline %i[hline]
        vline %i[vline]

        cline %i[slant thin],             angle: 52.0
        cline %i[connective thin dashed], angle: 30.0

        def call
          lines   multiple: param.square
          squares multiple: param.square
        end
      end
    end
  end
end
