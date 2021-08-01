# frozen_string_literal: true

require 'ostruct'

module Diesis
  module Application
    module Mixins
      module Conditions
        When = Struct.new :paper, :orientation, :property do
          def self.call(*args)
            new(*args).freeze
          end
        end

        Then = Class.new OpenStruct do
          def self.call(**kwargs)
            new(**kwargs).freeze
          end
        end

        def match!(property)
          unless conditions.key?(coming = When.(paper.type, paper.orientation.value, property))
            raise NonApplicableError, "Sheet #{property} not applicable for this type of paper and/or orientation."
          end

          conditions.fetch(coming).to_h.each do |key, value|
            param.send("#{key}=", value)
          end
        end

        def self.included(klass)
          super

          klass.extend Support::ClassAttribute
          klass.define :conditions, instance_reader: true

          constants.each do |const_name|
            klass.const_set(const_name, const_get(const_name))
          end
        end
      end
    end
  end
end
