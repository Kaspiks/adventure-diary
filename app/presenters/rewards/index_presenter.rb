# frozen_string_literal: true

module Rewards
  class IndexPresenter < ApplicationPresenter
    attr_reader :rewards, :current_user

    has_many_decorated :rewards, expose: true

    def initialize(rewards:, current_user:)
      super()
      @rewards = rewards
      @current_user = current_user
    end

    def total_count
      rewards.count
    end

    def user_points
      current_user&.reward_points || 0
    end

    def can_afford?(reward)
      return false unless current_user

      current_user.can_afford?(reward.cost_points)
    end
  end
end

