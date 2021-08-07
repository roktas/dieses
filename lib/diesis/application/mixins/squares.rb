# frozen_string_literal: true

module Diesis
  module Application
    module Mixins
      module Squares
        def squares(unit: Undefined, square: Undefined)
          param = self.param

          draw unit: Undefined.default(unit, param.unit), multiple: Undefined.default(square, param.square) do
            repeat do
              repeat do
                rect :rect, width: param.square, height: param.square, style: Style.(stroke: 'blue', 'stroke-width': '0.2', fill: 'none') # rubocop:disable Layout/LineLength
                right param.square
              end
              down param.square
            end
          end
        end
      end
    end
  end
end
