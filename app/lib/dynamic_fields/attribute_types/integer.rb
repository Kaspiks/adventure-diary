# frozen_string_literal: true

module DynamicFields
  module AttributeTypes
    class Integer < Base
      field_extensions do |type|
        define_method("#{type.name}=") do |value|
          instance_variable_set("@#{type.name}", value.to_i)
        end
      end

      def from_storage_data(value, **)
        value.to_i if value.present?
      end

      def to_storage_data(value, **)
        value.to_i if value.present?
      end

      def blank_value(**)
        options[:default] || 0
      end
    end
  end
end
