# frozen_string_literal: true

class ChallengePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    return true if admin?
    return true if record.is_active?

    user&.administrator? || record.owned_by?(user)
  end

  def create?
    user&.can_create_challenges?
  end

  def update?
    return true if admin?
    return true if user&.administrator?

    user&.company_user? && record.owned_by?(user)
  end

  def destroy?
    return true if admin?
    return true if user&.administrator?

    user&.company_user? && record.owned_by?(user)
  end

  def start?
    return false unless user
    return true if admin? || user.administrator?

    record.is_active?
  end

  def review_attempts?
    return true if admin?
    return true if user&.administrator?

    user&.company_user? && record.owned_by?(user)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin? || user&.administrator?
        scope.all
      elsif user&.company_user?
        scope.where(is_active: true).or(scope.where(creator_user_id: user.id))
      else
        scope.active
      end
    end
  end
end
