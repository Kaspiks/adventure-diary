# frozen_string_literal: true

# Centralized definition of all challenge field types
class ChallengeFields
  FIELD_TYPES = {
    text_input: {
      name: "Text Input",
      icon: "text",
      challenge_types: %w[quiz exploration],
      config_fields: %i[label instructions required points correct_answer],
      form_fields: %i[text_input],
      show_fields: %i[label instructions text_value]
    },
    single_choice: {
      name: "Single Choice",
      icon: "radio",
      challenge_types: %w[quiz],
      config_fields: %i[label instructions required points options correct_answer],
      form_fields: %i[radio_buttons],
      show_fields: %i[label instructions selected_option]
    },
    multiple_choice: {
      name: "Multiple Choice",
      icon: "checkbox",
      challenge_types: %w[quiz],
      config_fields: %i[label instructions required points options correct_answers],
      form_fields: %i[checkboxes],
      show_fields: %i[label instructions selected_options]
    },
    photo_upload: {
      name: "Photo Upload",
      icon: "camera",
      challenge_types: %w[photo checkin exploration social],
      config_fields: %i[label instructions required max_photos require_caption],
      form_fields: %i[file_upload],
      show_fields: %i[label instructions photos]
    },
    hidden_letter: {
      name: "Hidden Letter",
      icon: "eye",
      challenge_types: %w[exploration],
      config_fields: %i[label instructions required points image_url display_text number_of_blanks case_sensitive correct_answer hint],
      form_fields: %i[hidden_letter_puzzle],
      show_fields: %i[label instructions image display_text user_answer]
    }
  }.freeze

  def self.types
    FIELD_TYPES
  end

  def self.for_challenge_type(challenge_type_code)
    return FIELD_TYPES if challenge_type_code.blank?

    FIELD_TYPES.select do |_key, config|
      config[:challenge_types].include?(challenge_type_code.to_s)
    end
  end

  def self.valid_type?(type)
    FIELD_TYPES.key?(type.to_sym)
  end

  def self.config_for(type)
    FIELD_TYPES[type.to_sym]
  end
end






