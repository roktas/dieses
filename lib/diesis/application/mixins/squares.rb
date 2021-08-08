# frozen_string_literal: true

module Diesis
  module Application
    module Mixins
      module Squares
        def squares(unit: Undefined, multiple: Undefined)
          param = self.param

          draw unit: Undefined.default(unit, param.unit), multiple: Undefined.default(multiple, param.multiple) do
            repeat do
              repeat do
                square :rect, width: multiple, style: Style.(stroke: 'blue', 'stroke-width': '0.2', fill: 'none') # rubocop:disable Layout/LineLength
                right multiple
              end
              down multiple
            end
          end
        end
      end
    end
  end
end
