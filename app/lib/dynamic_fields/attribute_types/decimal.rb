# frozen_string_literal: true

module DynamicFields
  module AttributeTypes
    class Decimal < Base
      field_extensions do |type|
        define_method("#{type.name}=") do |value|
          decimal_value = value.present? ? BigDecimal(value.to_s) : nil
          instance_variable_set("@#{type.name}", decimal_value)
        rescue ArgumentError
          instance_variable_set("@#{type.name}", nil)
        end
      end

      def from_storage_data(value, **)
        BigDecimal(value.to_s) if value.present?
      rescue ArgumentError
        nil
      end

      def to_storage_data(value, **)
        value&.to_f
      end

      def blank_value(**)
        options[:default]&.to_d
      end
    end
  end
end
