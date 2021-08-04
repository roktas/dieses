# frozen_string_literal: true

require 'forwardable'
require 'ostruct'

module Diesis
  module Application
    class Sheet
      module DSL
        def sheet(name, desc, default: Undefined)
          Sheets.register name, klass: self, desc: desc, default: default
        end

        def variant(key, desc, **kwargs)
          variants key.to_sym => Proto.new(name: key, desc: desc, param: Param.new(**kwargs))
        end

        def variate(**kwargs, &block)
          kwargs.transform_values! { |value| [*value] }

          builder = proc { |keys, values| Proto.(**keys.zip(values).to_h) }
          variants = [nil].product(*kwargs.values).map { |_, *values| builder.call(kwargs.keys, values) }
          variants.each do |variant|
            variant.instance_exec(&block)
            self.variant variant.name, variant.desc, **variant.to_h
          end
          variants
        end

        def self.extended(klass)
          super

          klass.extend Support::ClassAttribute

          klass.define :proto
          klass.define :variants, default: {}
          klass.define :param,    default: Param.new
        end
      end

      extend DSL

      class Proto < OpenStruct
        def derivate(**kwargs)
          self.class.new(name: name, desc: desc, **kwargs).freeze
        end

        def to_s
          name.to_s
        end

        def self.call(**kwargs)
          new(**kwargs)
        end

        def self.formatted(*protos, prefix: EMPTY_STRING)
          longest_length = protos.map { |proto| proto.name.to_s.length }.max

          protos.map do |proto|
            lines = ["#{prefix}#{proto.name.to_s.ljust(longest_length)}  #{proto.desc}"]
            lines = [*lines, *yield(proto)] if block_given?
            lines
          end.flatten.join("\n")
        end
      end

      extend Forwardable
      def_delegators :@pen, :draw

      attr_reader :paper, :variant

      def initialize(paper, variant: Undefined)
        @paper   = paper
        @variant = Undefined.equal?(variant) ? self.class.default_variant : self.class.variant!(variant)
        @param   = parametrize
        @canvas  = Canvas.new(paper)
        @pen     = Pen.new(@canvas)

        setup if respond_to? :setup
      end

      def produce(**kwargs)
        call
        canvas.render(**kwargs)
      end

      private

      attr_reader :canvas, :param

      def parametrize(**param)
        Param.new(**self.class.param.to_h, **variant.param.to_h, **param.to_h)
      end

      class << self
        def default_variant
          return variant!(default) unless Undefined.equal?(proto.default)

          variants.values.first
        end

        def variant!(name)
          raise Error, "No variant defined: #{self.class}" if variants.empty?
          raise Error, "No such variant for #{self.class}: #{name}" unless variants.key?(name = name.to_sym)

          variants[name]
        end
      end
    end
  end
end
