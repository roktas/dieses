# frozen_string_literal: true

module Diesis
  module Application
    module Sheets
      class Copperplate < Sheet
        sheet :copperplate, 'Copperplate worksheet'

        include Mixins::Scribes[:sextet].with unit: [5, 7], ratio: [3/2r, 2/1r]

        cline :slant,      angle: 55.0, style: Style.(stroke: 'blue', 'stroke-width': 0.1)
        cline :connective, angle: 50.0, style: Style.(stroke: 'blue', 'stroke-width': 0.07, 'stroke-dasharray': '2, 2')

        def call
          scribes
        end
      end
    end
  end
end
