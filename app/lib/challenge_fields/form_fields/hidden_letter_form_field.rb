# frozen_string_literal: true

module ChallengeFields
  module FormFields
    class HiddenLetterFormField < BaseFormField
      validates :answer, presence: true, if: :required?

      delegate :image_url, :display_text, :number_of_blanks, :case_sensitive?, :hint,
               to: :model_field
    end
  end
end
