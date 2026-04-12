# frozen_string_literal: true

module Attempts
  module ApproveActions
    class Form < ApplicationModelForm
      self.object_class_name = "ChallengeAttempt"

      attr_accessor :reviewer

      def create(attributes)
        self.reviewer = attributes[:reviewer]

        if object.final?
          errors.add(:base, :already_reviewed)
          return false
        end

        with_safe_transaction do
          points_to_award = Challenges::AwardPoints.calculate_points_for(object)

          object.update!(
            attempt_status: AttemptStatus.approved,
            reviewed_at: Time.current,
            reviewer_user: reviewer,
            score_awarded: points_to_award
          )

          award_points(points_to_award) unless points_already_awarded?
          true
        end
      end

      private

      def points_already_awarded?
        PointsHistory.exists?(
          user: object.user,
          challenge: object.challenge,
          reason_code: PointsHistory::REASON_CHALLENGE_AWARD
        )
      end

      def award_points(points)
        object.user.add_points!(
          points,
          reason_code: PointsHistory::REASON_CHALLENGE_AWARD,
          challenge: object.challenge
        )
      end
    end
  end
end
