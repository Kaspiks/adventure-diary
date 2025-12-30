# frozen_string_literal: true

module Admin
  module Rewards
    class OrdersPresenter < ApplicationPresenter
      attr_reader :reward, :orders

      has_one_decorated :reward, expose: true
      has_many_decorated :orders, expose: true

      def initialize(reward:, orders:)
        super()
        @reward = reward
        @orders = orders
      end

      def total_count
        orders.count
      end
    end
  end
end

