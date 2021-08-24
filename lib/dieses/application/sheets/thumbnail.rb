# frozen_string_literal: true

module Dieses
  module Application
    module Sheets
      class Thumbnail < Sheet
        sheet :thumbnail, 'Thumbnails'

        style linewidth: 0.3, color: '#007f80'

        DENSITY = {
          '1': Param.(row: 5, col: 3, width: 10, height: 10),
          '2': Param.(row: 4, col: 4, width: 8,  height: 10),
          '3': Param.(row: 5, col: 5, width: 6,  height: 8),
          '4': Param.(row: 6, col: 5, width: 6,  height: 6)
        }.freeze

        variate density: DENSITY.keys, unit: 5 do
          self.name = density

          param = DENSITY[density]
          self.desc = "Density #{density} (#{param.row}x#{param.col} thumbnails on A4 paper)"
        end

        def call
          row, col, width, height = DENSITY[param.density].to_a

          draw unit: param.unit do
            repeat row do
              repeat col do
                rect :rect, width: width, height: height
                right(width + 1.25)
              end
              down(height + 1.25)
            end
          end
        end
      end
    end
  end
end
