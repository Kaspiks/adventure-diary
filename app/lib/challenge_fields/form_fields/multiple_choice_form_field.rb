# frozen_string_literal: true

module ChallengeFields
  module FormFields
    class MultipleChoiceFormField < BaseFormField
      form_attribute :selected_answers, :array

      validates :selected_answers, presence: true, if: :required?

      def options
        model_field.options
      end

      def permitted_attributes
        [:answer, selected_answers: []]
      end

      def answer
        selected_answers
      end

      def answer=(value)
        self.selected_answers = value
      end
    end
  end
end
