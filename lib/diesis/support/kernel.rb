# frozen_string_literal: true

module Diesis
  module Support
    module Kernel
      def kwargs_to_s(**kwargs)
        new_kwargs = kwargs.transform_values do |value|
          case value
          when Array, Set              then value.to_a.join(' ')
          when String, Symbol, Numeric then value.to_s
          else                              raise ArgumentError, "Unexpected value type #{value.class}: #{value}"
          end
        end
        new_kwargs.map { |key, value| "#{key}='#{value}'" }.join ' '
      end

      def kwargs(kwargs, *keys, **defaults) # rubocop:disable Metrics/MethodLength
        return (kwargs = kwargs.to_h) if keys.empty? && defaults.empty?

        hash = {}
        [*keys, *defaults.keys].each do |key|
          hash[key = key.to_sym] = if kwargs.key?(key)
                                     kwargs[key]
                                   elsif defaults.key?(key)
                                     defaults[key]
                                   else
                                     Undefined
                                   end
        end
        hash
      end
    end

    extend Kernel
  end
end
