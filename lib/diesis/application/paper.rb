# frozen_string_literal: true

require 'delegate'

module Diesis
  module Application
    module Paper
      Dim = Struct.new(*%i[width height], keyword_init: true) do
        def self.call(width, height)
          new width: width, height: height
        end

        def short
          values.min
        end

        def long
          values.max
        end
      end

      Margin = Struct.new(*%i[top right bottom left], keyword_init: true) do # in CSS margin order
        def self.call(*args)
          values = case args.size
                   when 1            then Array.new(members.size, *args)
                   when members.size then args
                   else                   raise ArgumentError, "Incorrect number of arguments: #{args}"
                   end

          new(Hash[*members.zip(values).flatten])
        end

        def self.build(dim, short:, long:)
          kwargs = if dim.height > dim.width
                     { top: long, right: short, bottom: long, left: short }
                   else
                     { top: short, right: long, bottom: short, left: long }
                   end

          new(**kwargs)
        end
      end

      Variant = Struct.new :type, :name, :width, :height, :floor, :scale, keyword_init: true do
        def build # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
          dim = Dim.(width, height)

          if scale.nil? || (short = Support.approx(dim.short * scale)) < floor
            short = floor
            scale = floor / dim.short
          end

          long   = Support.approx(dim.long * scale)
          margin = Margin.build(dim, short: short, long: long)

          variant = self

          Paper.define_singleton_method(name) do |**kwargs|
            klass = Class.new(Instance)

            klass.type    variant.type
            klass.variant variant.name

            klass.new(*dim.values, **margin.to_h.merge(**kwargs))
          end
        end
      end

      module DSL
        VARIANTS = [
          { suffix: 'n', floor: 7.0  }, # Narrow margins (default)
          { suffix: 'm', floor: 12.0 }, # Medium margins: bare minimum margin to accommodate ISO 838 filing holes
          { suffix: 'w', floor: 20.0 }  # Wide margins: safe minimum margin to accommodate ISO 838 filing holes
        ].freeze

        def family(type, width:, height:, scale: nil)
          VARIANTS.map do |hash|
            name  = :"#{type}#{hash[:suffix]}"
            floor = hash[:floor]
            Variant.new(type: type, name: name, width: width, height: height, floor: floor, scale: scale).tap(&:build)
          end.first.tap do |variant| # rubocop:disable Style/MultilineBlockChain
            # set the first variant as the default paper
            (class << self; self; end).alias_method type, variant.name
          end
        end
      end

      class Instance < DelegateClass(Geometry::Rect)
        extend Support::ClassAttribute

        define :type,    instance_reader: true
        define :variant, instance_reader: true

        extend Forwardable
        def_delegators :@margin, *Margin.members

        def initialize(width, height, **margin)
          @margin = Margin.new(**margin)
          super(Geometry::Rect.new(width, height))
        end

        def inner
          @inner ||= shrink(width: left + right, height: top + bottom)
        end

        def orient(orientation)
          self.class.new((rect = super).width, rect.height, **margin.to_h)
        end

        def to_h
          super.merge(margin.to_h)
        end

        protected

        attr_reader :margin
      end

      extend DSL

      A4 = Dim.new width: 210.0, height: 297.0
      B4 = Dim.new width: 250.0, height: 353.0
      US = Dim.new width: 215.9, height: 279.4

      family :a3, width: A4.height,     height: A4.width * 2
      family :a4, width: A4.width,      height: A4.height
      family :a5, width: A4.height / 2, height: A4.width
      family :a6, width: A4.width  / 2, height: A4.height / 2

      family :b3, width: B4.height,     height: B4.width * 2
      family :b4, width: B4.width,      height: B4.height
      family :b5, width: B4.height / 2, height: B4.width
      family :b6, width: B4.width  / 2, height: B4.height / 2

      family :us, width: US.width,      height: US.height

      class << self
        alias letter us
      end
    end
  end
end
