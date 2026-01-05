# frozen_string_literal: true

module DynamicFields
  module AttributeTypes
    class DateTime < Base
      field_extensions do |type|
        define_method("#{type.name}=") do |value|
          datetime_value = case value
                           when ::DateTime, ::Time, ::ActiveSupport::TimeWithZone then value.to_datetime
                           when ::String then ::DateTime.parse(value) rescue nil
                           end
          instance_variable_set("@#{type.name}", datetime_value)
        end
      end

      def from_storage_data(value, **)
        case value
        when ::DateTime, ::Time then value.to_datetime
        when ::String then ::DateTime.parse(value) rescue nil
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
