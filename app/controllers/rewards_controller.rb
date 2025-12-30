# frozen_string_literal: true

class RewardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reward, only: [:show]

  def index
    @presenter = Rewards::IndexPresenter.new(
      rewards: policy_scope(Reward).includes(:owner_user).ordered,
      current_user: current_user
    )
  end

  def show
    authorize @reward
    @presenter = Rewards::ShowPresenter.new(reward: @reward, current_user: current_user)
  end

  private

  def set_reward
    @reward = Reward.find(params[:id])
  end
end

