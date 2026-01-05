# frozen_string_literal: true

module ChallengeFields
  module FormFields
    class SingleChoiceFormField < BaseFormField
      validates :answer, presence: true, if: :required?

      def options
        model_field.options
      end
    end
  end
end
