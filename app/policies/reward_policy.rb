# frozen_string_literal: true

class RewardPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    return true if record.is_active?
    return true if admin?
    return true if user&.administrator?

    record.owned_by?(user)
  end

  def create?
    user&.can_create_rewards?
  end

  def update?
    return true if admin?
    return true if user&.administrator?

    record.owned_by?(user)
  end

  def destroy?
    return true if admin?
    return true if user&.administrator?

    record.owned_by?(user)
  end

  def purchase?
    return false unless user
    return false unless record.is_active?
    return false if record.out_of_stock?

    user.can_afford?(record.cost_points)
  end

  def manage_orders?
    return true if admin?
    return true if user&.administrator?

    record.owned_by?(user)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin? || user&.administrator?
        scope.all
      elsif user&.company_user?
        scope.where(is_active: true).or(scope.where(owner_user_id: user.id))
      else
        scope.available
      end
    end
  end
end

