# frozen_string_literal: true

module Dieses
  module Application
    module Mixins
      module Squares
        def squares(unit: Undefined, multiple: Undefined)
          param = self.param

          draw unit: Undefined.default(unit, param.unit), multiple: Undefined.default(multiple, param.multiple) do
            repeat do
              repeat do
                square :square, :extrabroad, width: multiple
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
