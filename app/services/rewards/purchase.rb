# frozen_string_literal: true

module Rewards
  class Purchase
    class InsufficientPointsError < StandardError; end
    class RewardUnavailableError < StandardError; end
    class OutOfStockError < StandardError; end

    attr_reader :user, :reward, :order, :errors

    def initialize(user:, reward:)
      @user = user
      @reward = reward
      @errors = []
    end

    def call
      validate!
      process_purchase
      Result.new(success: true, order: order, errors: [])
    rescue InsufficientPointsError
      Result.new(success: false, order: nil, errors: ["Insufficient points to purchase this reward"])
    rescue RewardUnavailableError
      Result.new(success: false, order: nil, errors: ["This reward is not available for purchase"])
    rescue OutOfStockError
      Result.new(success: false, order: nil, errors: ["This reward is out of stock"])
    rescue ActiveRecord::RecordInvalid => e
      Result.new(success: false, order: nil, errors: e.record.errors.full_messages)
    rescue StandardError => e
      Result.new(success: false, order: nil, errors: [e.message])
    end

    private

    def validate!
      raise RewardUnavailableError unless reward.is_active?
      raise OutOfStockError if reward.out_of_stock?
      raise InsufficientPointsError unless user.can_afford?(reward.cost_points)
    end

    def process_purchase
      ActiveRecord::Base.transaction do
        user.lock!
        reward.lock!

        raise InsufficientPointsError unless user.can_afford?(reward.cost_points)
        raise OutOfStockError if reward.out_of_stock?

        @order = create_order
        deduct_user_points
        decrement_stock
      end
    end

    def create_order
      Order.create!(
        user: user,
        reward: reward,
        order_status: OrderStatus.pending,
        total_points: reward.cost_points
      )
    end

    def deduct_user_points
      user.deduct_points!(
        reward.cost_points,
        reason_code: PointsHistory::REASON_REWARD_PURCHASE,
        order: order
      )
    end

    def decrement_stock
      reward.decrement_stock! if reward.has_stock_limit?
    end

    class Result
      attr_reader :order, :errors

      def initialize(success:, order:, errors:)
        @success = success
        @order = order
        @errors = errors
      end

      def success?
        @success
      end

      def failure?
        !success?
      end
    end
  end
end

