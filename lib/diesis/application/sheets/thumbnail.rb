# frozen_string_literal: true

module Diesis
  module Application
    module Sheets
      class Thumbnail < Sheet
        sheet :thumbnail, 'Thumbnails'

        variate density: %i[medium compact], unit: 5 do
          self.name = density.to_s
          self.desc = "#{density} density"
        end

        include Mixins::Conditions

        conditions When.(:a4, :portrait,  :medium)  => Then.(row: 4, col: 4, width: 8, height: 10),
                   When.(:a4, :portrait,  :compact) => Then.(row: 5, col: 5, width: 6, height: 8),
                   When.(:a4, :landscape, :medium)  => Then.(row: 3, col: 6, width: 8, height: 10),
                   When.(:a4, :landscape, :compact) => Then.(row: 4, col: 7, width: 6, height: 8)

        def call # rubocop:disable Layout/MethodLength
          match! param.density

          param = self.param

          draw unit: param.unit do
            repeat param.row do
              width, height = param.width, param.height

              repeat param.col do
                rect :rect, width: width, height: height, style: Style.(stroke: 'blue', 'stroke-width': '0.2', fill: 'none') # rubocop:disable Metrics/LineLength
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
