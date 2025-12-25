# frozen_string_literal: true

module Admin
  class AttemptsController < BaseController
    before_action :set_attempt, only: [:show, :approve, :reject]

    def index
      @presenter = Admin::Attempts::IndexPresenter.new(
        attempts: policy_scope(ChallengeAttempt).includes(:challenge, :user, :attempt_status).ordered
      )
    end

    def show
      authorize @attempt
      @presenter = Admin::Attempts::ShowPresenter.new(attempt: @attempt)
    end

    def approve
      authorize @attempt

      return redirect_to admin_attempt_path(@attempt), alert: t(".already_final") if @attempt.final?

      ActiveRecord::Base.transaction do
        # Calculate score: use field-based scoring if challenge has fields
        points_to_award = calculate_points_to_award(@attempt)

        @attempt.update!(
          attempt_status: AttemptStatus.approved,
          reviewed_at: Time.current,
          reviewer_user: current_user,
          score_awarded: points_to_award
        )

        # Idempotent: only award points if not already awarded for this attempt
        unless points_already_awarded?(@attempt)
          @attempt.user.add_points!(
            points_to_award,
            reason_code: PointsHistory::REASON_CHALLENGE_AWARD,
            challenge: @attempt.challenge
          )
        end
      end

      redirect_to admin_attempt_path(@attempt), notice: t(".success")
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_attempt_path(@attempt), alert: e.message
    end

    def reject
      authorize @attempt

      return redirect_to admin_attempt_path(@attempt), alert: t(".already_final") if @attempt.final?

      @attempt.update!(
        attempt_status: AttemptStatus.rejected,
        reviewed_at: Time.current,
        reviewer_user: current_user,
        score_awarded: 0
      )

      redirect_to admin_attempt_path(@attempt), notice: t(".success")
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_attempt_path(@attempt), alert: e.message
    end

    private

    def set_attempt
      @attempt = ChallengeAttempt.find(params[:id])
    end

    def calculate_points_to_award(attempt)
      if attempt.challenge.has_fields?
        field_score = attempt.calculate_score
        if attempt.challenge.quiz_challenge?
          field_score
        else
          # For other challenge types with fields, combine field score with base points
          field_score + attempt.challenge.award_points
        end
      else
        attempt.challenge.award_points
      end
    end

    def points_already_awarded?(attempt)
      PointsHistory.exists?(
        user: attempt.user,
        challenge: attempt.challenge,
        reason_code: PointsHistory::REASON_CHALLENGE_AWARD
      )
    end
  end
end



