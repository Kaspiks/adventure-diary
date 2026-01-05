# frozen_string_literal: true

module ChallengeFields
  class TemplateField < DynamicFields::Fields::TemplateField
    CONFIG_FIELDS = {
      text_input: %i[correct_answer case_sensitive],
      single_choice: %i[options correct_answer],
      multiple_choice: %i[options correct_answers],
      photo_upload: %i[max_photos require_caption],
      hidden_letter: %i[image_url display_text number_of_blanks case_sensitive correct_answer hint]
    }.freeze

    def field_class
      ChallengeFields::Registry.field_class_for(type)
    end

    def form_field_class
      ChallengeFields::Registry.form_field_class_for(type)
    end

    def allowed_config_fields
      CONFIG_FIELDS[type] || []
    end

    def clean_config
      allowed = allowed_config_fields + %i[points]
      config.slice(*allowed)
    end

    def valid_type?
      ChallengeFields::Registry.valid_type?(type)
    end

    def type_definition
      ChallengeFields::Registry.definition_for(type)
    end

    def icon
      type_definition.icon
    end

    def type_name
      type_definition.name
    end

    def points
      config[:points].to_i
    end

    def to_h
      super.merge(clean_config)
    end

    def self.from_hash(hash)
      instance = super(hash)

      unless instance.valid_type?
        raise DynamicFields::UnknownFieldTypeError,
              "Invalid challenge field type: #{instance.type}"
      end

      instance
    rescue DynamicFields::UnknownFieldTypeError
      super(hash.merge(type: :text_input))
    end
  end
end
