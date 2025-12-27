# frozen_string_literal: true

module Admin
  module Attempts
    class RejectActionsController < Admin::BaseController
      before_action :set_attempt

      def create
        authorize @attempt, :reject?

        form = build_form(@attempt)

        if form.create(create_params)
          redirect_to admin_attempt_path(@attempt), notice: t("admin.attempts.reject.success")
        else
          redirect_to admin_attempt_path(@attempt), alert: form.errors.full_messages.join(", ")
        end
      end

      private

      def set_attempt
        @attempt = ChallengeAttempt.find(params[:id])
      end

      def build_form(attempt)
        ::Attempts::RejectActions::Form.new(attempt)
      end

      def create_params
        params.fetch(:admin_attempts_reject_actions_form, {}).permit.to_h.merge(reviewer: current_user)
      end
    end
  end
end
