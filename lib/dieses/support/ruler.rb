# frozen_string_literal: true

module Dieses
  module Support
    class Ruler
      def self.call(unit, multiple = 1)
        new unit, (multiple || 1)
      end

      def self.divide(unit:, multiple:, length:)
        ruler = new(unit, multiple)
        [ruler.division(length), ruler.even(length)]
      end

      attr_reader :unit, :multiple

      def initialize(unit, multiple = 1)
        @unit = unit.to_f
        @multiple = multiple.to_f
      end

      def major
        @major ||= multiple * unit
      end

      def even(length)
        major * division(length)
      end

      def division(length)
        (length / major).to_i.to_f
      end

      def measure(n)
        n * unit
      end
    end
  end
end
