# frozen_string_literal: true

module ChallengeFields
  class HiddenLetterField < BaseField
    def check_answer
      return true if !required? && answer.blank?
      return false if template_config(:correct_answer).blank?

      if template_config(:case_sensitive)
        answer.to_s.strip == template_config(:correct_answer).to_s.strip
      else
        answer.to_s.strip.downcase == template_config(:correct_answer).to_s.strip.downcase
      end
    end

    def image_url
      template_config(:image_url)
    end

    def display_text
      template_config(:display_text)
    end

    def number_of_blanks
      template_config(:number_of_blanks) || 1
    end

    def case_sensitive?
      template_config(:case_sensitive) || false
    end

    def hint
      template_config(:hint)
    end
  end
end
