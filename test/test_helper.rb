# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/focus'

Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]

require 'dieses'
