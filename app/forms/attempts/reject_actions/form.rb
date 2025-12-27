# frozen_string_literal: true

module Attempts
  module RejectActions
    class Form < ApplicationModelForm
      self.object_class_name = "ChallengeAttempt"

      attr_accessor :reviewer

      def initialize(attempt)
        super(attempt)
      end

      def create(attributes)
        self.reviewer = attributes[:reviewer]

        if object.final?
          errors.add(:base, "Attempt has already been reviewed")
          return false
        end

        object.assign_attributes(
          attempt_status: AttemptStatus.rejected,
          reviewed_at: Time.current,
          reviewer_user: reviewer,
          score_awarded: 0
        )

        save
      end
    end
  end
end
