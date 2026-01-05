# frozen_string_literal: true

module ChallengeFields
  class BaseField < DynamicFields::Fields::ModelField
    field_attribute :answer, :string

    def check_answer
      true
    end

    def requires_photo?
      false
    end

    def field_type
      type
    end

    def type_name
      I18n.t("challenge_fields.types.#{type}", default: type.to_s.humanize)
    end
  end
end
