# frozen_string_literal: true

module Admin
  module Orders
    class IndexPresenter < ApplicationPresenter
      attr_reader :orders

      has_many_decorated :orders, expose: true

      def initialize(orders:)
        super()
        @orders = orders
      end

      def total_count
        orders.count
      end
    end
  end
end

