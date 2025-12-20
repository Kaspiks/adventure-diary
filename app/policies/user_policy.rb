# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    can?(:index)
  end

  def show?
    can?(:show) || user == record
  end

  def create?
    can?(:create)
  end

  def update?
    can?(:update) || user == record
  end

  def destroy?
    can?(:destroy) && user != record
  end

  def block?
    can?("users.block") && user != record
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin? || user&.has_permission?("users.index")
        scope.all
      else
        scope.where(id: user&.id)
      end
    end
  end
end
