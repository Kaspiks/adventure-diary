# frozen_string_literal: true

module DynamicFields
  class Registry
    FieldDefinition = Struct.new(:type, :field_class, :form_field_class, :show_field_class, :options, keyword_init: true)

    def initialize
      @definitions = {}
    end

    def register(type, field_class, form_field_class: nil, show_field_class: nil, **options)
      type_sym = type.to_sym

      @definitions[type_sym] = FieldDefinition.new(
        type: type_sym,
        field_class: field_class,
        form_field_class: form_field_class,
        show_field_class: show_field_class,
        options: options
      )
    end

    def registered?(type)
      @definitions.key?(type.to_sym)
    end

    def all
      @definitions.dup
    end

    def type_names
      @definitions.keys
    end

    def field_class_for(type)
      definition = fetch_definition(type)
      definition.field_class
    end

    def form_field_class_for(type)
      definition = fetch_definition(type)
      definition.form_field_class || infer_form_field_class(definition.field_class)
    end

    def show_field_class_for(type)
      definition = fetch_definition(type)
      definition.show_field_class || infer_show_field_class(definition.field_class)
    end

    def definition_for(type)
      fetch_definition(type)
    end

    def options_for(type)
      fetch_definition(type).options
    end

    private

    def fetch_definition(type)
      type_sym = type.to_sym
      @definitions[type_sym] || raise(UnknownFieldTypeError, "Unknown field type: #{type}")
    end

    def infer_form_field_class(field_class)
      namespace = field_class.name.deconstantize
      class_name = field_class.name.demodulize.sub(/Field\z/, "FormField")

      "#{namespace}::FormFields::#{class_name}".safe_constantize
    end

    def infer_show_field_class(field_class)
      namespace = field_class.name.deconstantize
      class_name = field_class.name.demodulize.sub(/Field\z/, "ShowField")

      "#{namespace}::ShowFields::#{class_name}".safe_constantize
    end
  end
end





