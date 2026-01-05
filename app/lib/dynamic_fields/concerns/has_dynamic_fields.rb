# frozen_string_literal: true

module DynamicFields
  module Concerns
    module HasDynamicFields
      extend ActiveSupport::Concern

      included do
        class_attribute :_dynamic_fields_column, default: :fields_config
        class_attribute :_template_field_class, default: "DynamicFields::Fields::TemplateField"

        before_save :persist_dynamic_fields
      end

      class_methods do
        def dynamic_fields_config(column: :fields_config, template_field_class: nil)
          self._dynamic_fields_column = column
          self._template_field_class = template_field_class if template_field_class
        end

        def template_field_class
          _template_field_class.constantize
        end
      end

      def template_fields
        @template_fields ||= load_template_fields
      end

      def template_fields=(fields)
        @template_fields = normalize_template_fields(fields)
        @_template_fields_changed = true
      end

      def add_template_field(field)
        field = normalize_template_field(field)
        field_with_position = set_field_position(field, template_fields.size)
        @template_fields = template_fields + [field_with_position]
        @_template_fields_changed = true
        field_with_position
      end

      def remove_template_field(field_id)
        @template_fields = template_fields.reject { |f| f.id == field_id }
        @_template_fields_changed = true
      end

      def has_template_fields?
        template_fields.any?
      end

      def template_field_count
        template_fields.size
      end

      def find_template_field(id)
        template_fields.find { |f| f.id == id }
      end

      def available_field_types
        DynamicFields.field_types
      end

      private

      def load_template_fields
        raw_config = public_send(_dynamic_fields_column) || []
        raw_config.map { |field_data| normalize_template_field(field_data) }
      end

      def normalize_template_fields(fields)
        return [] unless fields

        fields.map.with_index do |field, index|
          normalized = normalize_template_field(field)
          set_field_position(normalized, index)
        end
      end

      def normalize_template_field(field)
        case field
        when self.class.template_field_class
          field
        when Hash
          self.class.template_field_class.from_hash(field)
        else
          raise ArgumentError, "Invalid field type: #{field.class}"
        end
      end

      def set_field_position(field, position)
        return field if field.position == position

        # Create new field with updated position
        self.class.template_field_class.from_hash(
          field.to_h.merge(position: position)
        )
      end

      def persist_dynamic_fields
        return unless @_template_fields_changed

        field_data = template_fields.map(&:to_h)
        public_send("#{_dynamic_fields_column}=", field_data)
        @_template_fields_changed = false
      end
    end
  end
end
  