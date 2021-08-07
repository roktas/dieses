# frozen_string_literal: true

module Diesis
  module Application
    module Sheets
      class Thumbnail < Sheet
        sheet :thumbnail, 'Thumbnails'

        # rubocop:disable Layout/LineLength,Metrics/MethodLength
        variate row_col: [[4, 4], [5, 5], [3, 6], [4, 7]], width_height: [[8, 10], [6, 8]], unit: 5 do
          self.name = "#{row_col.first}x#{row_col.last}_#{width_height.first}x#{width_height.last}"
          self.desc = "#{row_col.first}x#{row_col.last} thumbnails of #{width_height.first} mm width x #{width_height.last} mm height"
        end

        def call
          param = self.param

          draw unit: param.unit do
            row,   col    = param.row_col
            width, height = param.width_height

            repeat row do
              repeat col do
                rect :rect, width: width, height: height, style: Style.(stroke: 'blue', 'stroke-width': '0.2', fill: 'none')
                right(width + 1)
              end
              down(height + 1)
            end
          end
        end
        # rubocop:enable Layout/LineLength,Metrics/MethodLength
      end
    end
  end
end
