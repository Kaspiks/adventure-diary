# frozen_string_literal: true

module DynamicFields
  module Fields
    class TemplateField
      attr_reader :id, :type, :label, :instructions, :required, :position, :config

      def initialize(id:, type:, label:, instructions: nil, required: true, position: 0, config: {})
        @id = id || SecureRandom.uuid
        @type = type.to_sym
        @label = label
        @instructions = instructions
        @required = required
        @position = position
        @config = config.deep_symbolize_keys
      end

      def uuid
        id
      end

      def valid_type?
        DynamicFields.valid_type?(type)
      end

      def field_class
        DynamicFields.field_class_for(type)
      end

      def form_field_class
        DynamicFields.form_field_class_for(type)
      end

      # Build a new model field instance for this template
      def build_model_field(object:, storage_data: {})
        field_class.build_from_template(
          template_field: self,
          object: object,
          storage_data: storage_data
        )
      end

      # Build a blank model field instance
      def build_blank_model_field(object:)
        field_class.build_blank(
          template_field: self,
          object: object
        )
      end

      # Serialize to hash for JSON storage
      def to_h
        {
          id: id,
          type: type.to_s,
          label: label,
          instructions: instructions,
          required: required,
          position: position
        }.merge(config).compact
      end

      alias to_hash to_h

      def self.from_hash(hash)
        hash = hash.deep_symbolize_keys

        known_keys = %i[id type label instructions required position]
        params = hash.slice(*known_keys)
        config = hash.except(*known_keys)

        new(**params, config: config)
      end

      def required?
        required
      end

      def [](key)
        config[key.to_sym]
      end

      def method_missing(method_name, *args)
        if config.key?(method_name)
          config[method_name]
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        config.key?(method_name) || super
      end
    end
  end
end
