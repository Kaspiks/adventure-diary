# frozen_string_literal: true

module ChallengeFields
  class SingleChoiceField < BaseField
    def check_answer
      return true if !required? && answer.blank?
      return false if template_config(:correct_answer).blank?

      answer.to_s == template_config(:correct_answer).to_s
    end

    def options
      template_config(:options) || []
    end
  end
end
