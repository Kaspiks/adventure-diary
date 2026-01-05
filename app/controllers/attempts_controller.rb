# frozen_string_literal: true

class AttemptsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_attempt, only: [:show, :edit, :update]

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

  def edit
    authorize @attempt, :edit?
    @presenter = Attempts::EditPresenter.new(attempt: @attempt, current_user: current_user)
  end

  def update
    authorize @attempt, :update?
    form = Attempts::EditForm.new(@attempt)

    if form.update(attempt_params)
      redirect_to attempt_path(@attempt), notice: t(".success")
    else
      @presenter = Attempts::EditPresenter.new(attempt: @attempt, current_user: current_user)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_attempt
    @attempt = ChallengeAttempt.find(params[:id])
  end

  def attempt_params
    params.require(:attempts_edit_form).permit(
      :evidence_url,
      answers: {},
      photos: {}
    )
  end
end
