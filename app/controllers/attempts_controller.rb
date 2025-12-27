# frozen_string_literal: true

class AttemptsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_attempt, only: [:show]

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

  private

  def set_attempt
    @attempt = ChallengeAttempt.find(params[:id])
  end
end
