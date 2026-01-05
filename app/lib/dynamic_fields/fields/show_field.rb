# frozen_string_literal: true

module DynamicFields
  module Fields
    class ShowField
      attr_reader :model_field

      delegate :template_field, :template_field_uuid, :uuid, :type, :label,
               :instructions, :position, :required, :required?, :config,
               :template_config, :points, :check_answer,
               to: :model_field

      def initialize(model_field:)
        @model_field = model_field
      end

      class << self
        def build_from_model_field(model_field)
          new(model_field: model_field)
        end

        def build_from_model_fields(model_fields)
          model_fields.map { |mf| build_from_model_field(mf) }
        end
      end

      def partial_name
        self.class.name.demodulize.sub(/ShowField\z/, "").underscore
      end

      def partial_path
        "dynamic_fields/show_fields/#{partial_name}"
      end

      def method_missing(method_name, *args, &block)
        if model_field.respond_to?(method_name)
          model_field.public_send(method_name, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        model_field.respond_to?(method_name) || super
      end
    end
  end
end
