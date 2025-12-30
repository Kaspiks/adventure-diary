# frozen_string_literal: true

module Orders
  class ShowPresenter < ApplicationPresenter
    attr_reader :order, :current_user

    has_one_decorated :order, expose: true

    def initialize(order:, current_user:)
      super()
      @order = order
      @current_user = current_user
    end

    def can_manage?
      return true if current_user&.admin?
      return true if current_user&.administrator?

      order.reward_owned_by?(current_user)
    end
  end
end

