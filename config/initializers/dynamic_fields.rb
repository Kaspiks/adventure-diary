# frozen_string_literal: true

require_relative "../../app/lib/challenge_fields"

Rails.application.config.after_initialize do
  ChallengeFields::Registry.register_with_dynamic_fields!
end
