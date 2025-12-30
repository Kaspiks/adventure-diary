# frozen_string_literal: true

module Admin
  class OrdersController < BaseController
    before_action :set_order, only: [:show]

    def index
      orders = Order.for_reward_owner(current_user)
                    .includes(:user, :reward, :order_status)
                    .ordered

      orders = Order.includes(:user, :reward, :order_status).ordered if current_user.admin? || current_user.administrator?

      @presenter = Admin::Orders::IndexPresenter.new(orders: orders)
    end

    def show
      authorize @order
      @presenter = Admin::Orders::ShowPresenter.new(order: @order)
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end
  end
end

