# frozen_string_literal: true

module Rewards
  class PurchaseActionsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_reward

    def create
      authorize @reward, :purchase?

      form = build_form

      if form.create
        redirect_to order_path(form.order), notice: t(".success")
      else
        redirect_to reward_path(@reward), alert: form.errors.full_messages.join(", ")
      end
    end

    private

    def set_reward
      @reward = Reward.find(params[:reward_id])
    end

    def build_form
      ::Rewards::PurchaseForm.new(user: current_user, reward: @reward)
    end
  end
end

