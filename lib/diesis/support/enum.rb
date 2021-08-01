# frozen_string_literal: true

module Diesis
  module Support
    class Enum
      extend ClassAttribute

      define :values, behave: :assign, instance_reader: true

      attr_reader :value

      def initialize(value)
        self.value = value
      end

      def value=(value)
        raise ArgumentError, "Invalid enum value: #{value}" unless self.class.values.member?(value = value.to_sym)

        @value = value
      end

      def eql?(other)
        return false unless other.is_a? self.class

        value == other.value
      end

      alias == eql?

      def hash
        self.class.hash ^ values.hash ^ value.hash
      end

      def to_s
        value.to_s
      end

      class << self
        require 'set'

        def of(*members) # rubocop:disable Metrics/MethodLength
          values Set.new(members.map(&:to_sym)).freeze

          members.each do |member|
            define_method("#{member}?") do
              value == member
            end
          end

          Class.new(self) do
            def self.call(value)
              new(value)
            end

            define_singleton_method(:default) { members.first }
          end
        end
      end

      private_class_method :new
    end
  end
end
