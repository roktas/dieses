# frozen_string_literal: true

module Dieses
  module Application
    module Sheets
      class Table < Sheet
        sheet :table, 'Table'

        style linewidth: 0.2, color: '#007f80'

        DENSITY = {
          '1': Param.(row: 2,  col: 2),
          '2': Param.(row: 5,  col: 2),
          '3': Param.(row: 4,  col: 4),
          '4': Param.(row: 10, col: 4)
        }.freeze

        variate density: DENSITY.keys, unit: 1 do
          self.name = density

          param = DENSITY[density]
          self.desc = "Density #{density} (#{param.row}x#{param.col} table on A4 paper)"
        end

        def call # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
          row, col = DENSITY[param.density].to_a

          cell_width,  total_width  = Ruler.divide(unit: param.unit, multiple: col, length: canvas.width)
          cell_height, total_height = Ruler.divide(unit: param.unit, multiple: row, length: canvas.height)

          draw unit: param.unit do
            repeat row + 1 do
              hline :hline, length: total_width
              down cell_height
            end
            repeat col + 1 do
              vline :vline, length: total_height
              right cell_width
            end
            repeat row do
              down cell_height / 2
              hline :half, :dashed, :fine, length: total_width
              down cell_height / 2
            end
          end
        end
      end
    end
  end
end
