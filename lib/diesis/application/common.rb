# frozen_string_literal: true

require 'ostruct'

module Diesis
  module Application
    Error = Class.new Error

    NotImplementedError = Class.new Error
    NonApplicableError  = Class.new Error

    Style = Class.new OpenStruct do
      def self.call(**kwargs)
        new(**kwargs)
      end
    end

    Param = Class.new OpenStruct
  end
end
