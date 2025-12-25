# frozen_string_literal: true

class ChallengesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_challenge, only: [:show, :start]

  def index
    @presenter = Challenges::IndexPresenter.new(
      challenges: policy_scope(Challenge).includes(:challenge_type, :difficulty_level, :award_point_level, :location).ordered,
      current_user: current_user
    )
  end

  def show
    authorize @challenge
    @presenter = Challenges::ShowPresenter.new(challenge: @challenge, current_user: current_user)
  end

  def start
    authorize @challenge

    existing_attempt = current_user.challenge_attempts
                                   .for_challenge(@challenge)
                                   .non_final
                                   .first

    if existing_attempt
      redirect_to my_attempts_path, notice: t(".already_started")
      return
    end

    attempt = ChallengeAttempt.new(
      user: current_user,
      challenge: @challenge,
      attempt_status: AttemptStatus.started,
      started_at: Time.current
    )

    if attempt.save
      redirect_to my_attempts_path, notice: t(".success")
    else
      redirect_to challenge_path(@challenge), alert: t(".failure")
    end
  end

  private

  def set_challenge
    @challenge = Challenge.find(params[:id])
  end
end



