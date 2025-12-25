# frozen_string_literal: true

class AttemptsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_attempt, only: [:show, :submit, :approve, :reject]

  def index
    @presenter = Attempts::IndexPresenter.new(
      attempts: policy_scope(ChallengeAttempt).includes(:challenge, :attempt_status, :user).ordered,
      current_user: current_user
    )
  end

  def show
    authorize @attempt
    @presenter = Attempts::ShowPresenter.new(attempt: @attempt, current_user: current_user)
  end

  def submit
    authorize @attempt

    ActiveRecord::Base.transaction do
      @attempt.evidence_url = params[:evidence_url]
      
      save_attempt_answers
      save_attempt_artifacts

      unless @attempt.validate_submission
        raise ActiveRecord::RecordInvalid.new(@attempt)
      end

      @attempt.attempt_status = AttemptStatus.submitted
      @attempt.submitted_at = Time.current

      if @attempt.save
        redirect_to my_attempts_path, notice: t(".success")
      else
        raise ActiveRecord::RecordInvalid.new(@attempt)
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to attempt_path(@attempt), alert: e.record.errors.full_messages.join(", ")
  rescue StandardError => e
    redirect_to attempt_path(@attempt), alert: e.message
  end

  def approve
    authorize @attempt

    return redirect_to attempt_path(@attempt), alert: t(".already_final") if @attempt.final?

    ActiveRecord::Base.transaction do
      # Calculate score: use field-based scoring if challenge has fields, otherwise use base points
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

    redirect_to attempt_path(@attempt), notice: t(".success")
  rescue ActiveRecord::RecordInvalid => e
    redirect_to attempt_path(@attempt), alert: e.message
  end

  def reject
    authorize @attempt

    return redirect_to attempt_path(@attempt), alert: t(".already_final") if @attempt.final?

    @attempt.update!(
      attempt_status: AttemptStatus.rejected,
      reviewed_at: Time.current,
      reviewer_user: current_user,
      score_awarded: 0
    )

    redirect_to attempt_path(@attempt), notice: t(".success")
  rescue ActiveRecord::RecordInvalid => e
    redirect_to attempt_path(@attempt), alert: e.message
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
        # For other challenge types with fields (like photo + quiz combo), combine both
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

  def save_attempt_answers
    return unless params[:answers].present?

    params[:answers].each do |field_id, answer_value|
      next if answer_value.blank?

      answer = @attempt.attempt_answers.find_or_initialize_by(field_id: field_id.to_s)
      
      if answer_value.is_a?(Array)
        answer.answer_value = answer_value.first
        answer.answer_data = { "values" => answer_value }
      else
        answer.answer_value = answer_value.to_s
        answer.answer_data = {}
      end

      # Auto-check correctness if field has correct_answer
      field = @attempt.challenge.fields.find { |f| f.id == field_id.to_s }
      if field
        answer.is_correct = field.check_answer(answer_value)
      end

      answer.save!
    end
  end

  def save_attempt_artifacts
    return unless params[:photos].present?

    params[:photos].each do |field_id, photo_files|
      Array(photo_files).each do |photo_file|
        next unless photo_file.present?

        artifact = @attempt.attempt_artifacts.build(
          kind: 'photo',
          field_id: field_id.to_s
        )
        artifact.file.attach(photo_file)
        artifact.save!
      end
    end
  end
end


