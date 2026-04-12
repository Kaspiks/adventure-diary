# frozen_string_literal: true

module Attempts
  class SubmitActionsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_attempt

    def update
      authorize @attempt, :submit?

      form = build_form(@attempt)

      if form.update(update_params)
        redirect_to attempt_path(@attempt), notice: t("attempts.submit.success")
      else
        redirect_to attempt_path(@attempt), alert: form.errors.full_messages.join(", ")
      end
    end

    private

    def set_attempt
      @attempt = ChallengeAttempt.find(params[:id])
    end

    def build_form(attempt)
      Attempts::SubmitActions::Form.new(attempt)
    end

    def update_params
      params.require(:attempts_submit_actions_form).permit(
        :evidence_url,
        :user_latitude,
        :user_longitude,
        answers: {},
        photos: {},
        photo_captions: {}
      )
    end
  end
end
