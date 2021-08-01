# frozen_string_literal: true

require_relative '../test_helper'

module Diesis
  class SupportTest < Minitest::Test
    def test_precision_default
      assert_equal(Support::Float::PRECISION, Support::Float.precision)
    end

    def test_precision_attribute
      Support::Float.precision = 100
      assert_equal(100, Support::Float.precision)
      Support::Float.precision = Support::Float::PRECISION
      assert_equal(Support::Float::PRECISION, Support::Float.precision)
    end

    def test_almost_equal
      Support::Float.precision = 8

      assert(Support.almost_equal(1.999_999_999, 2.0))
      refute(Support.almost_equal(1.999_999_999, 2.0, precision: 9))
      refute(Support.almost_equal(1.999, 2.0, precision: nil))

      Support::Float.precision = Support::Float::PRECISION
    end
  end
end
