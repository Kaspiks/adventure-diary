# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show]

  def index
    @presenter = Orders::IndexPresenter.new(
      orders: policy_scope(Order).includes(:reward, :order_status).ordered,
      current_user: current_user
    )
  end

  def show
    authorize @order
    @presenter = Orders::ShowPresenter.new(order: @order, current_user: current_user)
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end
end

