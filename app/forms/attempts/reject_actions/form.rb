# frozen_string_literal: true

module Attempts
  module RejectActions
    class Form < ApplicationModelForm
      self.object_class_name = "ChallengeAttempt"

      attr_accessor :reviewer

      def create(attributes)
        self.reviewer = attributes[:reviewer]

        if object.final?
          errors.add(:base, :already_reviewed)
          return false
        end

        rejected_status = AttemptStatus.rejected
        if rejected_status.nil?
          errors.add(:base, :status_not_found)
          return false
        end

        object.assign_attributes(
          attempt_status: rejected_status,
          reviewed_at: Time.current,
          reviewer_user: reviewer,
          score_awarded: 0
        )

        save
      end
    end
  end
end
