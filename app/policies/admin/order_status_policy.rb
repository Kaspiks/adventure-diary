# frozen_string_literal: true

module Admin
  class OrderStatusPolicy < ApplicationPolicy
    def index?
      can?("order_statuses.index")
    end

    def new?
      can?("order_statuses.create")
    end

    def create?
      new?
    end

    def edit?
      can?("order_statuses.update")
    end

    def update?
      edit?
    end
  end
end

