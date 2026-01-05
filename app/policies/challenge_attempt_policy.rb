# frozen_string_literal: true

class ChallengeAttemptPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    return true if admin?
    return true if user&.administrator?
    return true if record.owned_by?(user)

    user&.company_user? && record.challenge.owned_by?(user)
  end

  def submit?
    return false unless user
    return false unless record.owned_by?(user)
    return false if record.final?

    record.can_submit?
  end

  def edit?
    return false unless user
    return false unless record.owned_by?(user)
    return false if record.final?

    record.submitted?
  end

  def update?
    edit?
  end

  def approve?
    return false unless user
    return false unless record.can_review?
    return true if admin?
    return true if user.administrator?

    user.company_user? && record.challenge.owned_by?(user)
  end

  def reject?
    approve?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin? || user&.administrator?
        scope.all
      elsif user&.company_user?
        scope.joins(:challenge)
             .where(challenges: { creator_user_id: user.id })
             .or(scope.where(user_id: user.id))
      else
        scope.where(user_id: user.id)
      end
    end
  end
end
