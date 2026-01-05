# frozen_string_literal: true

module DynamicFields
  module AttributeTypes
    class ArrayType < Base
      def from_storage_data(value, **)
        return [] if value.nil?

        value.is_a?(::Array) ? value.compact_blank : []
      end

      def to_storage_data(value, **)
        return [] if value.nil?

        result = value.is_a?(::Array) ? value : [value]
        result.compact_blank
      end

      def from_form_input(value, **)
        case value
        when ::Array
          value.compact_blank
        when ::String
          value.split(options[:delimiter] || ",").map(&:strip).compact_blank
        else
          []
        end
      end

      def blank_value(**)
        []
      end

      def permitted_params(**)
        { name.to_sym => [] }
      end
    end
  end
end
