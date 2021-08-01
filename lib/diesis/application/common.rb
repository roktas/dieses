# frozen_string_literal: true

require 'ostruct'

module Diesis
  module Application
    Error = Class.new Error

    NotImplementedError = Class.new Error
    NonApplicableError  = Class.new Error

    struct = Class.new OpenStruct do
      def self.call(**kwargs)
        new(**kwargs)
      end

      def to_a
        to_h.values
      end
    end

    Style = Class.new struct
    Param = Class.new struct

    Orientation = Geometry::Rect::Orientation
  end
end
