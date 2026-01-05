# frozen_string_literal: true

module DynamicFields
  module Concerns
    module HasDynamicForm
      extend ActiveSupport::Concern

      included do
        class_attribute :_dynamic_form_model_method, default: :object

        attr_writer :form_fields

        validate :validate_form_fields
      end

      class_methods do
        def dynamic_form_config(model_method: :object)
          self._dynamic_form_model_method = model_method
        end
      end

      def dynamic_fields_model
        public_send(_dynamic_form_model_method)
      end

      def form_fields
        @form_fields ||= build_form_fields
      end

      def form_fields_attributes=(attributes)
        return if attributes.blank?

        attrs_list = attributes.is_a?(Hash) ? attributes.values : attributes

        attrs_list.each do |field_attrs|
          next if field_attrs.blank?

          field_id = field_attrs[:template_field_id] || field_attrs["template_field_id"]
          form_field = form_fields.find { |f| f.template_field_uuid == field_id }

          next unless form_field

          assignable_attrs = field_attrs.except(:template_field_id, "template_field_id")
          form_field.assign_attributes(assignable_attrs)
        end
      end

      def form_fields_permitted_attributes
        permitted = form_fields.map do |form_field|
          { form_field.template_field_uuid => form_field.permitted_attributes }
        end

        { form_fields_attributes: permitted }
      end

      def build_model_fields_from_form
        form_fields.map(&:to_model_field)
      end

      def update_template_fields(template_fields_params)
        return if template_fields_params.blank?

        normalized_fields = template_fields_params.map do |field_params|
          field_params = field_params.to_h.deep_symbolize_keys
          
          next nil if field_params[:_destroy].present?

          field_params
        end.compact

        dynamic_fields_model.template_fields = normalized_fields
      end

      private

      def build_form_fields
        dynamic_fields_model.template_fields.map do |template_field|
          form_field_class = DynamicFields.form_field_class_for(template_field.type)
          
          model_field = template_field.build_blank_model_field(object: dynamic_fields_model)
          
          form_field_class.build_from_model_field(model_field, object: self)
        end
      end

      def validate_form_fields
        invalid_fields = form_fields.reject { |f| f.valid?(validation_context) }
        return if invalid_fields.empty?

        errors.add(:form_fields, :invalid)
      end
    end
  end
end
