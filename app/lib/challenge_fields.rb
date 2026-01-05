# frozen_string_literal: true

require_relative "dynamic_fields"
module ChallengeFields
  class << self

    def config
      ConfigLoader.default
    end

    def types
      Registry::FIELD_TYPES
    end

    def for_challenge_type(challenge_type_code)
      available_configs = config.field_types_for(challenge_type_code)
      available_type_symbols = available_configs.map(&:type)

      Registry::FIELD_TYPES.select { |type, _| available_type_symbols.include?(type) }
    end

    def valid_type?(type)
      Registry.valid_type?(type)
    end

    def field_type_available?(challenge_type_code, field_type)
      config.field_type_available?(challenge_type_code, field_type)
    end

    def config_for(type)
      Registry.definition_for(type)
    end

    def field_class_for(type)
      Registry.field_class_for(type)
    end

    def form_field_class_for(type)
      Registry.form_field_class_for(type)
    end

    def options_for_select(challenge_type_code = nil)
      config.options_for_select(challenge_type_code)
    end


    def defaults_for(challenge_type_code, field_type)
      config.defaults_for(challenge_type_code, field_type)
    end

    def reload_config!
      ConfigLoader.reset!
      config.reload!
    end
  end
end

# Load ChallengeFields submodules
require_relative "challenge_fields/config_loader"
require_relative "challenge_fields/template_field"
require_relative "challenge_fields/base_field"
require_relative "challenge_fields/text_input_field"
require_relative "challenge_fields/single_choice_field"
require_relative "challenge_fields/multiple_choice_field"
require_relative "challenge_fields/photo_upload_field"
require_relative "challenge_fields/hidden_letter_field"
require_relative "challenge_fields/form_fields/base_form_field"
require_relative "challenge_fields/form_fields/text_input_form_field"
require_relative "challenge_fields/form_fields/single_choice_form_field"
require_relative "challenge_fields/form_fields/multiple_choice_form_field"
require_relative "challenge_fields/form_fields/photo_upload_form_field"
require_relative "challenge_fields/form_fields/hidden_letter_form_field"
require_relative "challenge_fields/registry"
