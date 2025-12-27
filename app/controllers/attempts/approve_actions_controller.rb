# frozen_string_literal: true

module Attempts
  class ApproveActionsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_attempt

    def create
      authorize @attempt, :approve?

      form = build_form(@attempt)

      if form.create(create_params)
        redirect_to attempt_path(@attempt), notice: t("attempts.approve.success")
      else
        redirect_to attempt_path(@attempt), alert: form.errors.full_messages.join(", ")
      end
    end

    private

    def set_attempt
      @attempt = ChallengeAttempt.find(params[:id])
    end

    def build_form(attempt)
      Attempts::ApproveActions::Form.new(attempt)
    end

    def create_params
      params.fetch(:attempts_approve_actions_form, {}).permit.to_h.merge(reviewer: current_user)
    end
  end
end
