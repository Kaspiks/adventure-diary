# frozen_string_literal: true

module ChallengeFields
  class MultipleChoiceField < BaseField
    field_attribute :selected_answers, :array

    def check_answer
      return true if !required? && selected_answers.blank?
      return false if correct_answers.blank?

      given = selected_answers.map(&:to_s).sort
      expected = correct_answers.map(&:to_s).sort

      given == expected
    end

    def options
      template_config(:options) || []
    end

    def correct_answers
      template_config(:correct_answers) || []
    end

    def answer
      selected_answers
    end

    def answer=(value)
      self.selected_answers = value
    end
  end
end
