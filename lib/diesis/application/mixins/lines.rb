# frozen_string_literal: true

module Diesis
  module Application
    module Mixins
      module Lines
        module ClassMethods
          Line = Struct.new :tag, :after, :style, :step, keyword_init: true

          def hline(tag, after: Undefined, style: EMPTY_HASH)
            (param.hlines ||= []) << Line.new(tag: tag, after: after, style: style)
          end

          def vline(tag, after: Undefined, style: EMPTY_HASH)
            (param.vlines ||= []) << Line.new(tag: tag, after: after, style: style)
          end

          Cross = Struct.new :tag, :angle, :style, keyword_init: true

          def cline(tag, angle:, style: EMPTY_HASH)
            (param.clines ||= []) << Cross.new(tag: tag, angle: angle, style: style)
          end
        end

        module InstanceMethods
          def lines(unit: Undefined, multiple: Undefined)
            step_lines(param)

            unit     = Undefined.default(unit, param.unit)
            multiple = Undefined.default(multiple, param.multiple || param.hlines&.map(&:step)&.sum)

            draw_hlines unit: unit, multiple: multiple
            draw_vlines unit: unit, multiple: multiple
            draw_clines unit: unit, multiple: multiple
          end

          private

          def step_lines(param)
            [*param.hlines, *param.vlines].compact.each do |line|
              line.step = case line.after
                          when Proc                then param.instance_exec(&line.after)
                          when Numeric             then line.after
                          when Undefined, NilClass then 1
                          else                          raise ArgumentError, "Wrong type for after: #{line.after.class}"
                          end
            end
          end

          def draw_hlines(unit:, multiple:)
            return unless param.hlines

            param = self.param

            draw unit: unit, multiple: multiple do
              repeat do
                param.hlines.each do |line|
                  hline line.tag, style: line.style
                  down line.step
                end
              end
            end
          end

          def draw_vlines(unit:, multiple:)
            return unless param.vlines

            param = self.param

            draw unit: unit, multiple: multiple do
              repeat do
                param.vlines.each do |line|
                  vline line.tag, style: line.style
                  right line.step
                end
              end
            end
          end

          def draw_clines(unit:, multiple:) # rubocop:disable Metrics/MethodLength
            return unless param.clines

            param = self.param

            draw unit: unit, multiple: multiple do
              repeat do
                param.clines.each do |slant|
                  repeat do
                    cline slant.tag, angle: slant.angle, style: slant.style
                    cross
                  end
                end
              end
            end
          end
        end

        def self.included(base)
          base.extend ClassMethods
          base.include InstanceMethods
        end
      end
    end
  end
end