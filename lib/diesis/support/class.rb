# frozen_string_literal: true

module Diesis
  module Support
    # Stolen and improved from dry-rb/dry-core
    module ClassAttribute
      module Value
        Update = Object.new.tap do |object|
          def object.call(current_value, new_value)
            raise ArgumentError, "Value must be updateable: #{new_value}" unless new_value.respond_to? :[]

            current_value.tap { new_value.each { |k, v| current_value[k.to_sym] = v } }
          end
        end.freeze

        Append = Object.new.tap do |object|
          def object.call(current_value, new_value)
            raise ArgumentError, "Value must be appendable: #{new_value}" unless new_value.respond_to? :<<

            current_value.tap { new_value.each { |v| current_value << v } }
          end
        end.freeze

        Assign = Object.new.tap do |object|
          def object.call(_, new_value)
            new_value.dup
          end
        end.freeze

        class << self
          def behave(behave, value = Const::Undefined)
            Const::Undefined.equal?(behave) ? implicit(value) : explicit(behave)
          end

          private

          # Map given symbol to relevant module
          def explicit(behave)
            const_get behave.to_s.capitalize
          rescue NameError
            raise ArgumentError, "Unrecognized behave: #{behave}"
          end

          # Deduce semantics from a value
          def implicit(value)
            require 'ostruct'
            require 'set'

            case value
            when ::Hash, ::Struct, ::OpenStruct then Update
            when ::Array, ::Set                 then Append
            else                                     Assign
            end
          end
        end
      end

      private_constant :Value

      # rubocop:disable Metrics/MethodLength,Layout/LineLength,Lint/RedundantCopDisableDirective
      def define(name, default: Const::Undefined, behave: Const::Undefined, inherit: true, instance_reader: false)
        ivar   = :"@#{name}"
        behave = Value.behave(behave, default)

        instance_variable_set(ivar, default.dup)

        mod = ::Module.new do
          define_method(name) do |new_value = Const::Undefined|
            if Const::Undefined.equal?(new_value)
              return instance_variable_defined?(ivar) ? instance_variable_get(ivar) : nil
            end

            instance_variable_set(
              ivar,
              behave.(
                instance_variable_defined?(ivar) ? instance_variable_get(ivar) : instance_variable_set(ivar, default.dup),
                new_value
              )
            )
          end

          define_method(:inherited) do |klass|
            klass.send(name, (inherit ? send(name) : default).dup)

            super(klass)
          end
        end

        extend(mod)

        define_method(name) { self.class.send(name) } if instance_reader
      end
      # rubocop:enable Metrics/MethodLength,Layout/LineLength,Lint/RedundantCopDisableDirective

      def defines(*names, behave: Const::Undefined)
        names.each { |name| define(name, behave: behave) }
      end
    end
  end
end
