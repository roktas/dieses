# frozen_string_literal: true

module Dieses
  module Application
    module Mixins
      class Scribes < Module
        def self.[](type)
          raise ArgumentError, "No such Scribes type available: #{type}" unless Bundle.method_defined? type

          new(type)
        end

        def initialize(type)
          super()
          @type = type.to_sym
        end

        def with(unit:, ratio: [1/1r], gap: [0])
          tap do
            @unit  = unit
            @ratio = ratio
            @gap   = gap
          end
        end

        module ClassMethods
          def variate_scribes(unit:, ratio: [1/1r], gap: [0])
            variate(unit: unit, ratio: ratio, gap: gap) do
              self.name = :"#{self.unit}#{self.ratio.to_s.delete('/')}#{self.gap}"
              self.desc = "#{self.unit} mm x-height with #{self.ratio} ratio and #{self.gap} mm gap"
            end
          end
        end

        module InstanceMethods
          def scribes
            param.x_height = 1.0
            param.height   = param.hlines.size > 2 ? 2 * param.ratio / (param.hlines.size - 2) : 1

            lines
          end
        end

        module Bundle
          def quartet
            hline %i[ascender thick],  after: proc { height   }
            hline %i[waist],           after: proc { x_height }
            hline %i[base altcolor],   after: proc { height   }
            hline %i[descender thick], after: proc { gap      }
          end

          # codebeat:disable[ABC]
          def sextet
            hline %i[ascender2 thick],   after: proc { height   }
            hline %i[ascender1 dashed],  after: proc { height   }
            hline %i[waist],             after: proc { x_height }
            hline %i[base altcolor],     after: proc { height   }
            hline %i[descender1 dashed], after: proc { height   }
            hline %i[descender2 thick],  after: proc { gap      }
          end
          # codebeat:enable[ABC]
        end

        def included(base)
          base.include Lines

          base.extend ClassMethods
          base.include InstanceMethods

          base.extend Bundle

          base.variate_scribes(unit: @unit, ratio: @ratio, gap: @gap) if @unit

          base.send(@type)
        end
      end
    end
  end
end
