# frozen_string_literal: true

module DynamicFields
  module AttributeTypes
    class Boolean < Base
      TRUE_VALUES = [true, 1, "1", "true", "yes", "on"].freeze

      field_extensions do |type|
        define_method("#{type.name}=") do |value|
          bool_value = TRUE_VALUES.include?(value)
          instance_variable_set("@#{type.name}", bool_value)
        end

        define_method("#{type.name}?") do
          !!public_send(type.name)
        end
      end

      def from_storage_data(value, **)
        TRUE_VALUES.include?(value)
      end

      def to_storage_data(value, **)
        TRUE_VALUES.include?(value)
      end

      def from_form_input(value, **)
        TRUE_VALUES.include?(value)
      end

      def blank_value(**)
        options[:default] || false
      end
    end
  end
end
