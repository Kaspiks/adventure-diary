# frozen_string_literal: true

module ChallengeFields
  module FormFields
    class TextInputFormField < BaseFormField
      validates :answer, presence: true, if: :required?
    end
  end
end
