# frozen_string_literal: true

module DynamicFields
  # Custom errors
  UnknownFieldTypeError = Class.new(StandardError)
  InvalidAttributeTypeError = Class.new(StandardError)
  MissingTemplateFieldError = Class.new(StandardError)

  class << self
    def registry
      @registry ||= Registry.new
    end

    def register_field_type(type_name, field_class, **options)
      registry.register(type_name, field_class, **options)
    end

    def field_types
      registry.all
    end

    def valid_type?(type)
      registry.registered?(type)
    end

    def field_class_for(type)
      registry.field_class_for(type)
    end

    def form_field_class_for(type)
      registry.form_field_class_for(type)
    end

    def show_field_class_for(type)
      registry.show_field_class_for(type)
    end

    def attribute_type(name)
      type_name = name.to_s.camelize
      type_name = "#{type_name}Type" if %w[Array].include?(type_name)

      AttributeTypes.const_get(type_name)
    rescue NameError
      raise InvalidAttributeTypeError, "Unknown attribute type: #{name}"
    end
  end
end

require_relative "dynamic_fields/field_extensions"
require_relative "dynamic_fields/registry"

require_relative "dynamic_fields/attribute_types/base"
require_relative "dynamic_fields/attribute_types/string"
require_relative "dynamic_fields/attribute_types/integer"
require_relative "dynamic_fields/attribute_types/boolean"
require_relative "dynamic_fields/attribute_types/decimal"
require_relative "dynamic_fields/attribute_types/array_type"
require_relative "dynamic_fields/attribute_types/date"
require_relative "dynamic_fields/attribute_types/date_time"

require_relative "dynamic_fields/fields/template_field"
require_relative "dynamic_fields/fields/model_field"
require_relative "dynamic_fields/fields/form_field"
require_relative "dynamic_fields/fields/show_field"

require_relative "dynamic_fields/concerns/has_dynamic_fields"
require_relative "dynamic_fields/concerns/has_dynamic_form"
