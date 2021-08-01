# frozen_string_literal: true

module Diesis
  module Application
    module Sheets
      class Cursive < Sheet
        sheet :cursive, 'Cursive worksheet'

        include Mixins::Scribe[:quartet].with unit: [5, 7, 10]

        slant :slant, angle: 60.0,
                      style: Style.(stroke: 'blue', 'stroke-width': 0.05)
      end
    end
  end
end
