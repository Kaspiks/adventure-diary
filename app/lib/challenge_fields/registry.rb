# frozen_string_literal: true

module ChallengeFields
  class Registry
    FieldTypeDefinition = Struct.new(
      :type,
      :name,
      :icon,
      :challenge_types,
      :field_class,
      :form_field_class,
      keyword_init: true
    )

    FIELD_TYPES = {
      text_input: {
        name: "Text Input",
        icon: "text",
        challenge_types: %w[quiz exploration],
        field_class: "ChallengeFields::TextInputField",
        form_field_class: "ChallengeFields::FormFields::TextInputFormField"
      },
      single_choice: {
        name: "Single Choice",
        icon: "radio",
        challenge_types: %w[quiz exploration],
        field_class: "ChallengeFields::SingleChoiceField",
        form_field_class: "ChallengeFields::FormFields::SingleChoiceFormField"
      },
      multiple_choice: {
        name: "Multiple Choice",
        icon: "checkbox",
        challenge_types: %w[quiz exploration],
        field_class: "ChallengeFields::MultipleChoiceField",
        form_field_class: "ChallengeFields::FormFields::MultipleChoiceFormField"
      },
      photo_upload: {
        name: "Photo Upload",
        icon: "camera",
        challenge_types: %w[photo checkin exploration social],
        field_class: "ChallengeFields::PhotoUploadField",
        form_field_class: "ChallengeFields::FormFields::PhotoUploadFormField"
      },
      hidden_letter: {
        name: "Hidden Letter",
        icon: "eye",
        challenge_types: %w[exploration],
        field_class: "ChallengeFields::HiddenLetterField",
        form_field_class: "ChallengeFields::FormFields::HiddenLetterFormField"
      }
    }.freeze

    class << self
      def all
        @all ||= FIELD_TYPES.transform_values do |config|
          FieldTypeDefinition.new(config)
        end
      end

      def for_challenge_type(challenge_type_code)
        return all if challenge_type_code.blank?

        all.select do |_type, definition|
          definition.challenge_types.include?(challenge_type_code.to_s)
        end
      end

      def valid_type?(type)
        FIELD_TYPES.key?(type.to_sym)
      end

      def definition_for(type)
        all[type.to_sym] || raise(DynamicFields::UnknownFieldTypeError, "Unknown type: #{type}")
      end

      def field_class_for(type)
        definition_for(type).field_class.constantize
      end

      def form_field_class_for(type)
        definition_for(type).form_field_class.constantize
      end

      def options_for_select(challenge_type_code = nil)
        types = challenge_type_code ? for_challenge_type(challenge_type_code) : all
        types.map { |type, definition| [definition.name, type] }
      end

      def register_with_dynamic_fields!
        FIELD_TYPES.each do |type, config|
          DynamicFields.register_field_type(
            type,
            config[:field_class].constantize,
            form_field_class: config[:form_field_class].constantize
          )
        end
      end
    end
  end
end
