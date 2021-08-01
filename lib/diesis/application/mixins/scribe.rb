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
          Line = Struct.new :tag, :after, :style, :step, keyword_init: true

          def line(tag, after: Undefined, style: EMPTY_HASH)
            (param.lines ||= []) << Line.new(tag: tag, after: after, style: style)
          end

          def vline(tag, after: Undefined, style: EMPTY_HASH)
            (param.vlines ||= []) << Line.new(tag: tag, after: after, style: style)
          end

          Slant = Struct.new :tag, :angle, :style, keyword_init: true

          def slant(tag, angle:, style: EMPTY_HASH)
            (param.slants ||= []) << Slant.new(tag: tag, angle: angle, style: style)
          end

          def scribes(unit:, ratio: [1/1r], gap: [0])
            variate(unit: unit, ratio: ratio, gap: gap) do
              self.name = :"#{self.unit}#{self.ratio.to_s.delete('/')}#{self.gap}"
              self.desc = "#{self.unit} x-height with #{self.ratio} ratio and #{self.gap} gap"
            end
          end
        end

        module InstanceMethods
          def setup # rubocop:disable Metrics/AbcSize
            param.x_height = 1.0
            param.height   = param.lines.size > 2 ? 2 * param.ratio / (param.lines.size - 2) : 1

            param.multiple = param.lines.sum do |line|
              line.step = case line.after
                          when Proc     then param.instance_exec(&line.after)
                          when Numeric  then line.after
                          when NilClass then 0
                          else               raise ArgumentError, "Wrong type for after: #{line.after.class}"
                          end
            end
          end

          def call # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/PerceivedComplexity
            param = self.param

            draw unit: param.unit, multiple: param.multiple do
              repeat do
                param.lines.each do |line|
                  hline line.tag, style: line.style
                  down line.step
                end
              end

              # FIXME
              repeat do
                param.vlines&.each do |line|
                  vline line.tag, style: line.style
                  right(line.step || 1)
                end
              end

              param.slants&.each do |slant|
                repeat do
                  cline slant.tag, angle: slant.angle, style: slant.style
                  cross
                end
              end
            end
          end
        end

        module Mixins
          def quartet
            line :ascender,  after: proc { height },
                             style: Style.(stroke: 'blue', 'stroke-width': '0.2')
            line :waist,     after: proc { x_height },
                             style: Style.(stroke: 'grey', 'stroke-width': '0.1', 'stroke-dasharray': '2, 2')
            line :base,      after: proc { height },
                             style: Style.(stroke: 'red',  'stroke-width': '0.1', 'stroke-dasharray': '2, 2')
            line :descender, after: proc { gap },
                             style: Style.(stroke: 'blue', 'stroke-width': '0.2')
          end

          def sextet # rubocop:disable Metrics/MethodLength
            line :ascender2,  after: proc { height },
                              style: Style.(stroke: 'blue', 'stroke-width': '0.2')
            line :ascender1,  after: proc { height },
                              style: Style.(stroke: 'grey', 'stroke-width': '0.1', 'stroke-dasharray': '2, 2')
            line :waist,      after: proc { x_height },
                              style: Style.(stroke: 'grey', 'stroke-width': '0.1')
            line :base,       after: proc { height },
                              style: Style.(stroke: 'red',  'stroke-width': '0.1')
            line :descender1, after: proc { height },
                              style: Style.(stroke: 'grey', 'stroke-width': '0.1', 'stroke-dasharray': '2, 2')
            line :descender2, after: proc { gap },
                              style: Style.(stroke: 'blue', 'stroke-width': '0.2')
          end
        end

        def included(base)
          base.extend ClassMethods
          base.include InstanceMethods
          base.extend Mixins

          base.scribes(unit: @unit, ratio: @ratio, gap: @gap) if @unit

          base.send(@type)
        end
      end
    end
  end
end
