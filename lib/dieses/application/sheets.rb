# frozen_string_literal: true

module Dieses
  module Application
    module Sheets
      @registry = {}

      def self.available?(name)
        @registry.key? name.to_sym
      end

      def self.register(name, klass:, desc:, default: nil)
        @registry[name = name.to_sym] = Sheet::Proto.new(name:    name,
                                                         desc:    desc,
                                                         klass:   klass,
                                                         default: default).tap do |proto|
          klass.proto proto
        end
      end

      def self.proto(name)
        raise Error, "No such sheet available: #{name}" unless @registry[name = name.to_sym]

        @registry[name]
      end

      def self.sheet(name)
        proto(name).klass
      end

      def self.call(name, paper, variant: nil, param: {})
        sheet(name).new(paper, variant, **param).call
      end

      def self.available
        @registry.sort.to_h.transform_values do |proto|
          proto.derivate(variants: proto.klass.variants.values.map(&:derivate))
        end
      end

      def self.defaults
        {}.tap do |defaults|
          available.each_key do |name|
            defaults[name] = sheet(name).default_variant
          end
        end
      end

      def self.dump(prefix: '')
        Sheet::Proto.formatted(*available.values, prefix: prefix) do |proto|
          Sheet::Proto.formatted(*proto.variants, prefix: prefix * 2)
        end
      end

      Dir[File.join(__dir__, 'sheets', '*.rb')].each { |file| require file }
    end
  end
end
