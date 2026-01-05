# frozen_string_literal: true

module DynamicFields
  module AttributeTypes
    class Date < Base
      field_extensions do |type|
        define_method("#{type.name}=") do |value|
          date_value = case value
                       when ::Date then value
                       when ::String then ::Date.parse(value) rescue nil
                       end
          instance_variable_set("@#{type.name}", date_value)
        end
      end

      def from_storage_data(value, **)
        case value
        when ::Date then value
        when ::String then ::Date.parse(value) rescue nil
        end
      end

      def to_storage_data(value, **)
        value&.iso8601
      end

      def blank_value(**)
        nil
      end
    end
  end
end
