# frozen_string_literal: true

module DynamicFields
  module AttributeTypes
    class Base
      include FieldExtensions

      attr_reader :name, :options

      field_extensions do |type|
        attr_accessor type.name
      end

      def initialize(name, **options)
        @name = name.to_s
        @options = options
      end

      def from_storage_data(value, instance: nil)
        value
      end

      def to_storage_data(value, instance: nil)
        value
      end

      def from_form_input(value, instance: nil)
        value
      end

      def to_form_input(value, instance: nil)
        value
      end

      def blank_value(instance: nil)
        nil
      end

      def prepare_for_persistence(value, instance: nil)
      end

      def permitted_params(instance: nil)
        name.to_sym
      end
    end
  end
end
