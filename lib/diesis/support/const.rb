# frozen_string_literal: true

require 'set'

module Diesis
  module Support
    module Const
      # Copied from https://github.com/dry-rb/dry-core.  All kudos to the original authors.

      # An empty array
      EMPTY_ARRAY = [].freeze
      # An empty hash
      EMPTY_HASH = {}.freeze
      # An empty list of options
      EMPTY_OPTS = {}.freeze
      # An empty set
      EMPTY_SET = ::Set.new.freeze
      # An empty string
      EMPTY_STRING = ''
      # Identity function
      IDENTITY = (->(x) { x }).freeze

      Undefined = Object.new.tap do |undefined| # rubocop:disable Metrics/BlockLength
        const_set(:Self, -> { Undefined })

        def undefined.to_s
          'Undefined'
        end

        def undefined.inspect
          'Undefined'
        end

        def undefined.default(x, y = self)
          if equal?(x)
            if equal?(y)
              yield
            else
              y
            end
          else
            x
          end
        end

        def undefined.map(value)
          if equal?(value)
            self
          else
            yield(value)
          end
        end

        def undefined.dup
          self
        end

        def undefined.clone
          self
        end

        def undefined.coalesce(*args)
          args.find(Self) { |x| !equal?(x) }
        end
      end.freeze

      def self.included(base)
        super

        constants.each do |const_name|
          base.const_set(const_name, const_get(const_name))
        end
      end
    end
  end

  include Support::Const
end
