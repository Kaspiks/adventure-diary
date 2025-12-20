# frozen_string_literal: true

class RolePolicy < ApplicationPolicy
  def index?
    can?(:index)
  end

  def show?
    can?(:show)
  end

  def create?
    can?(:create)
  end

  def update?
    can?(:update)
  end

  def destroy?
    can?(:destroy) && !record.users.exists?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin? || user&.has_permission?("roles.index")
        scope.all
      else
        scope.none
      end
    end
  end
end


