# frozen_string_literal: true

module Challenges
  class StartActionsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_challenge

    def create
      authorize @challenge, :start?

      existing_attempt = find_existing_attempt
      if existing_attempt
        redirect_to my_attempts_path, notice: t("challenges.start.already_started")
        return
      end

      attempt = build_attempt
      form = build_form(attempt)

      if form.create(create_params)
        redirect_to attempt_path(attempt), notice: t("challenges.start.success")
      else
        redirect_to challenge_path(@challenge), alert: form.errors.full_messages.join(", ")
      end
    end

    private

    def set_challenge
      @challenge = Challenge.find(params[:challenge_id])
    end

    def find_existing_attempt
      current_user.challenge_attempts
                  .for_challenge(@challenge)
                  .non_final
                  .first
    end

    def build_attempt
      ChallengeAttempt.new(
        user: current_user,
        challenge: @challenge,
        attempt_status: AttemptStatus.started,
        started_at: Time.current
      )
    end

    def build_form(attempt)
      Challenges::StartActions::Form.new(attempt)
    end

    def create_params
      params.fetch(:challenges_start_actions_form, {}).permit.to_h
    end
  end
end
