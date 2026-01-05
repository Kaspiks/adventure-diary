# frozen_string_literal: true

module DynamicFields
  module Fields
    class FormField
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Validations

      class_attribute :form_field_attributes, default: []

      attr_reader :model_field, :object

      delegate :template_field, :template_field_uuid, :uuid, :type, :label,
               :instructions, :position, :required, :required?, :config,
               :template_config, :points,
               to: :model_field

      class << self
        def form_attribute(name, type_name, **options)
          type_class = resolve_type_class(type_name)
          type_instance = type_class.new(name, **options)

          type_instance.apply_extensions_to(self)

          self.form_field_attributes = form_field_attributes + [type_instance]
        end

        def build_from_model_field(model_field, object:)
          instance = new(model_field: model_field, object: object)
          instance.assign_from_model_field
          instance
        end

        private

        def resolve_type_class(type_name)
          case type_name
          when Class then type_name
          when Symbol, ::String then DynamicFields.attribute_type(type_name)
          else raise InvalidAttributeTypeError, "Invalid type: #{type_name}"
          end
        end
      end

      def initialize(model_field:, object:, **attributes)
        @model_field = model_field
        @object = object
        super()
        assign_attributes(attributes) if attributes.present?
      end

      # For form builder compatibility
      def persisted?
        model_field.uuid.present?
      end

      def assign_from_model_field
        form_field_attributes.each do |attr_type|
          model_value = model_field.public_send(attr_type.name)
          form_value = attr_type.to_form_input(model_value, instance: self)
          public_send("#{attr_type.name}=", form_value)
        end
      end

      def to_model_field
        attributes_hash = form_field_attributes.reduce({}) do |attrs, attr_type|
          form_value = public_send(attr_type.name)
          model_value = attr_type.from_form_input(form_value, instance: self)
          attrs.merge(attr_type.name.to_sym => model_value)
        end

        model_field.assign_attributes(attributes_hash)
        model_field
      end

      def permitted_attributes
        form_field_attributes.flat_map do |attr_type|
          attr_type.permitted_params(instance: self)
        end
      end

      def partial_name
        self.class.name.demodulize.sub(/FormField\z/, "").underscore
      end

      def partial_path
        "dynamic_fields/form_fields/#{partial_name}"
      end
    end
  end
end
