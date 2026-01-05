# frozen_string_literal: true

module ChallengeFields
  class TextInputField < BaseField
    def check_answer
      return true if !required? && answer.blank?
      return false if template_config(:correct_answer).blank?

      if template_config(:case_sensitive)
        answer.to_s.strip == template_config(:correct_answer).to_s.strip
      else
        answer.to_s.strip.downcase == template_config(:correct_answer).to_s.strip.downcase
      end
    end
  end
end
