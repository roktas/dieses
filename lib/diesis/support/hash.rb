# frozen_string_literal: true

module Diesis
  module Support
    module Hash
      def hashify_by(array_of_objects, attribute)
        {}.tap do |hash|
          array_of_objects.each do |object|
            hash[object.send(attribute)] = object
          rescue NoMethodError
            raise ArgumentError, "Object not respond to #{attribute}: #{object}"
          end
        end
      end
    end

    extend Hash
  end
end
