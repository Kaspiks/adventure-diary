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
          points_to_award = calculate_points

          object.update!(
            attempt_status: AttemptStatus.approved,
            reviewed_at: Time.current,
            reviewer_user: reviewer,
            score_awarded: points_to_award
          )

          award_points(points_to_award) unless points_already_awarded?
        end
      end

      private

      def calculate_points
        if object.challenge.has_fields?
          field_score = object.calculate_score
          if object.challenge.quiz_challenge?
            field_score
          else
            field_score + object.challenge.award_points
          end
        else
          object.challenge.award_points
        end
      end

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
