# frozen_string_literal: true

module Diesis
  module Support
    module ClassAttribute
      module Value
        BEHAVE = %i[update append assign].freeze # Keep the order

        def self.behave(behave, value = Undefined)
          unless Undefined.equal?(behave)
            begin
              return const_get behave.to_s.capitalize
            rescue NameError
              raise ArgumentError, "Unrecognized behave: #{behave}"
            end
          end

          BEHAVE.map { |c| const_get(c.to_s.capitalize) }.detect { |handler| handler.match?(value) } || DEFAULT
        end

        def self.value!(handler, new_value)
          raise ArgumentError, "Value must be #{handler}: #{new_value}" unless handler.match?(new_value)

          new_value
        end

        Update = Object.new.tap do |this|
          def this.match?(value)
            value.respond_to? :[]
          end

          def this.call(current_value, new_value)
            current_value.tap { Value.value!(self, new_value).each { |k, v| current_value[k.to_sym] = v } }
          end
        end.freeze

        Append = Object.new.tap do |this|
          def this.match?(value)
            value.respond_to? :<<
          end

          def this.call(current_value, new_value)
            current_value.tap { Value.value!(self, new_value).each { |v| current_value << v } }
          end
        end.freeze

        DEFAULT = Assign = Object.new.tap do |this|
          def this.match?(_)
            true
          end

          def this.call(_, new_value)
            Value.value!(self, new_value).dup
          end
        end.freeze
      end

      private_constant :Value

      def define(name, initial = Undefined, behave: Undefined, inherit: true, instance_reader: false) # rubocop:disable Metrics/MethodLength
        ivar    = :"@#{name}"
        handler = Value.behave(behave, initial)

        instance_variable_set(ivar, initial.dup)

        mod = ::Module.new do
          define_method(name) do |new_value = Undefined|
            if Undefined.equal?(new_value)
              return instance_variable_defined?(ivar) ? instance_variable_get(ivar) : nil
            end

            current_value = if instance_variable_defined?(ivar)
                              instance_variable_get(ivar)
                            else
                              instance_variable_set(ivar, initial.dup)
                            end

            instance_variable_set(ivar, handler.(current_value, new_value))
          end

          define_method(:inherited) do |klass|
            klass.send(name, (inherit ? send(name) : initial).dup)

            super(klass)
          end
        end

        extend(mod)

        define_method(name) { self.class.send(name) } if instance_reader
      end

      def defines(*names, behave: Undefined)
        names.each { |name| define(name, behave: behave) }
      end
    end
  end
end
