# frozen_string_literal: true

module Diesis
  module Application
    module Mixins
      class Scribe < Module
        def self.[](type)
          raise ArgumentError, "No such Scribe type available: #{type}" unless Mixins.method_defined? type

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
              self.desc = "#{self.unit} x-height with #{self.ratio} ratio and #{self.gap} gap"
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

        module Mixins
          def quartet
            hline :ascender,  after: proc { height },
                              style: Style.(stroke: 'blue', 'stroke-width': '0.2')
            hline :waist,     after: proc { x_height },
                              style: Style.(stroke: 'grey', 'stroke-width': '0.1', 'stroke-dasharray': '2, 2')
            hline :base,      after: proc { height },
                              style: Style.(stroke: 'red',  'stroke-width': '0.1', 'stroke-dasharray': '2, 2')
            hline :descender, after: proc { gap },
                              style: Style.(stroke: 'blue', 'stroke-width': '0.2')
          end

          # rubocop:disable Metrics/MethodLength
          # codebeat:disable[ABC]
          def sextet
            hline :ascender2,  after: proc { height },
                               style: Style.(stroke: 'blue', 'stroke-width': '0.2')
            hline :ascender1,  after: proc { height },
                               style: Style.(stroke: 'grey', 'stroke-width': '0.1', 'stroke-dasharray': '2, 2')
            hline :waist,      after: proc { x_height },
                               style: Style.(stroke: 'grey', 'stroke-width': '0.1')
            hline :base,       after: proc { height },
                               style: Style.(stroke: 'red',  'stroke-width': '0.1')
            hline :descender1, after: proc { height },
                               style: Style.(stroke: 'grey', 'stroke-width': '0.1', 'stroke-dasharray': '2, 2')
            hline :descender2, after: proc { gap },
                               style: Style.(stroke: 'blue', 'stroke-width': '0.2')
          end
          # codebeat:enable[ABC]
          # rubocop:enable Metrics/MethodLength
        end

        def included(base)
          base.include Application::Mixins::Lines

          base.extend ClassMethods
          base.include InstanceMethods

          base.extend Mixins

          base.variate_scribes(unit: @unit, ratio: @ratio, gap: @gap) if @unit

          base.send(@type)
        end
      end
    end
  end
end
