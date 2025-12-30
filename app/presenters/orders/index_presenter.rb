# frozen_string_literal: true

module Orders
  class IndexPresenter < ApplicationPresenter
    attr_reader :orders, :current_user

    has_many_decorated :orders, expose: true

    def initialize(orders:, current_user:)
      super()
      @orders = orders
      @current_user = current_user
    end

    def total_count
      orders.count
    end
  end
end

