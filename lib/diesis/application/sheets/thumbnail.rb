# frozen_string_literal: true

module Diesis
  module Application
    module Sheets
      class Thumbnail < Sheet
        sheet :thumbnail, 'Thumbnails'

        DENSITY = {
          '1': Param.(row: 4, col: 4, width: 8, height: 10),
          '3': Param.(row: 3, col: 6, width: 8, height: 10),
          '2': Param.(row: 5, col: 5, width: 6, height: 8),
          '4': Param.(row: 4, col: 7, width: 6, height: 8)
        }.freeze

        variate density: %i[1 2 3 4], unit: 5 do
          self.name = density.to_s
          self.desc = "Density #{density}"
        end

        def call
          row, col, width, height = DENSITY[param.density].to_a

          draw unit: param.unit do
            repeat row do
              repeat col do
                rect :rect, width: width, height: height, style: Style.(stroke: 'blue', 'stroke-width': '0.2', fill: 'none') # rubocop:disable Layout/LineLength
                right(width + 1)
              end
              down(height + 1)
            end
          end
        end
      end
    end
  end
end
