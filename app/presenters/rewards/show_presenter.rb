# frozen_string_literal: true

module Rewards
  class ShowPresenter < ApplicationPresenter
    attr_reader :reward, :current_user

    has_one_decorated :reward, expose: true

    def initialize(reward:, current_user:)
      super()
      @reward = reward
      @current_user = current_user
    end

    def user_points
      current_user&.reward_points || 0
    end

    def can_afford?
      return false unless current_user

      current_user.can_afford?(reward.cost_points)
    end

    def can_purchase?
      return false unless current_user
      return false unless reward.is_active?
      return false if reward.out_of_stock?

      can_afford?
    end

    def points_needed
      return 0 if can_afford?

      reward.cost_points - user_points
    end
  end
end

