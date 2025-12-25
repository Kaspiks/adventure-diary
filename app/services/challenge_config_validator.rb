# frozen_string_literal: true

class ChallengeConfigValidator
  def self.validate(challenge_config)
    new(challenge_config).validate
  end

  def initialize(challenge_config)
    @challenge_config = challenge_config
    @schema = challenge_config.challenge_type_schema
  end

  def validate
    return { valid: false, errors: ['No schema associated'] } unless @schema

    validator = @schema.schema_validator
    return { valid: false, errors: ['Schema is invalid'] } unless validator

    result = validator.validate(@challenge_config.config_json)
    errors = result.map { |e| format_error(e) }

    { valid: errors.empty?, errors: errors }
  end

  private

  def format_error(error)
    path = error['data_pointer']
    message = error['error']
    "#{path}: #{message}"
  end
end


