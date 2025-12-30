# frozen_string_literal: true

module Rewards
  class PurchaseForm < ApplicationForm
    attr_reader :user, :reward, :order

    def initialize(user:, reward:)
      super()
      @user = user
      @reward = reward
    end

    def create(_attributes = {})
      result = ::Rewards::Purchase.new(user: user, reward: reward).call

      if result.success?
        @order = result.order
        true
      else
        result.errors.each { |error| errors.add(:base, error) }
        false
      end
    end
  end
end

