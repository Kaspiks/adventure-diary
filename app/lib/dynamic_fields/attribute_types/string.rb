# frozen_string_literal: true

module DynamicFields
  module AttributeTypes
    class String < Base
      def from_storage_data(value, **)
        value.to_s if value.present?
      end

      def to_storage_data(value, **)
        value.to_s.presence
      end

      def blank_value(**)
        ""
      end
    end
  end
end
