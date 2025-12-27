# frozen_string_literal: true

module Admin
  class AttemptsController < BaseController
    before_action :set_attempt, only: [:show]

    def index
      @presenter = Admin::Attempts::IndexPresenter.new(
        attempts: policy_scope(ChallengeAttempt).includes(:challenge, :user, :attempt_status).ordered
      )
    end

    def show
      authorize @attempt
      @presenter = Admin::Attempts::ShowPresenter.new(attempt: @attempt)
    end

    private

    def set_attempt
      @attempt = ChallengeAttempt.find(params[:id])
    end
  end
end
