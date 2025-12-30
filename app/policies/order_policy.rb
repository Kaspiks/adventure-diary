# frozen_string_literal: true

class OrderPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    return true if admin?
    return true if user&.administrator?
    return true if record.owned_by?(user)

    record.reward_owned_by?(user)
  end

  def update_status?
    return true if admin?
    return true if user&.administrator?

    record.reward_owned_by?(user)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin? || user&.administrator?
        scope.all
      else
        scope.for_user(user)
      end
    end
  end

  class CompanyScope < ApplicationPolicy::Scope
    def resolve
      if user&.admin? || user&.administrator?
        scope.all
      elsif user&.company_user?
        scope.for_reward_owner(user)
      else
        scope.none
      end
    end
  end
end

