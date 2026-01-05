# frozen_string_literal: true

module DynamicFields
  module Fields
    class ModelField
      include ActiveModel::Model
      include ActiveModel::Attributes

      class_attribute :field_attributes, default: []

      attr_accessor :uuid
      attr_reader :template_field, :object

      delegate :type, :label, :instructions, :position, :required, :required?, :config,
               to: :template_field

      class << self
        def field_attribute(name, type_name, **options)
          type_class = resolve_type_class(type_name)
          type_instance = type_class.new(name, **options)

          type_instance.apply_extensions_to(self)

          self.field_attributes = field_attributes + [type_instance]
        end

        def build_from_template(template_field:, object:, storage_data:)
          instance = new(template_field: template_field, object: object)
          instance.assign_from_storage_data(storage_data)
          instance
        end

        def build_blank(template_field:, object:)
          instance = new(template_field: template_field, object: object)
          instance.prepare_blank_attributes
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

      def initialize(template_field:, object:, **attributes)
        @template_field = template_field
        @object = object
        @uuid = nil
        super()
        assign_attributes(attributes) if attributes.present?
      end

      # Get template field UUID (for matching)
      def template_field_uuid
        template_field.uuid
      end

      def assign_from_storage_data(storage_data)
        self.uuid = storage_data[:uuid]

        field_attributes.each do |attr_type|
          value = attr_type.from_storage_data(
            storage_data[attr_type.name.to_sym],
            instance: self
          )
          public_send("#{attr_type.name}=", value) unless value.nil?
        end
      end

      def to_storage_data
        base_data = { uuid: uuid, template_field_uuid: template_field.uuid }

        field_attributes.reduce(base_data) do |data, attr_type|
          value = public_send(attr_type.name)
          storage_value = attr_type.to_storage_data(value, instance: self)
          data.merge(attr_type.name.to_sym => storage_value)
        end.compact
      end

      def prepare_blank_attributes
        field_attributes.each do |attr_type|
          blank_value = attr_type.blank_value(instance: self)
          public_send("#{attr_type.name}=", blank_value)
        end
      end

      def prepare_for_persistence
        self.uuid ||= SecureRandom.uuid

        field_attributes.each do |attr_type|
          value = public_send(attr_type.name)
          attr_type.prepare_for_persistence(value, instance: self)
        end
      end

      def template_config(key)
        template_field.config[key.to_sym]
      end

      def check_answer
        true
      end

      def points
        template_config(:points).to_i
      end
    end
  end
end
