# frozen_string_literal: true

module ChallengeFieldsHelper
  def render_field_config(field, index, form_builder)
    render partial: "admin/challenges/fields/config/#{field.type}", 
           locals: { field: field, index: index, f: form_builder }
  end

  def render_field_form(field, attempt, form_builder)
    render partial: "attempts/fields/form/#{field.type}",
           locals: { field: field, attempt: attempt, f: form_builder }
  end

  def render_field_show(field, attempt)
    render partial: "attempts/fields/show/#{field.type}",
           locals: { field: field, attempt: attempt }
  end

  def available_field_types_for(challenge_type_code)
    ChallengeFields.for_challenge_type(challenge_type_code)
  end

  def field_type_name(type)
    ChallengeFields.config_for(type)&.dig(:name) || type.to_s.humanize
  end
end






