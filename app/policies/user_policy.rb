# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index? = admin?
  def show? = admin? || user == record
  def create? = admin?
  def update? = admin? || user == record
  def destroy? = admin? && user != record

  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.admin? ? scope.all : scope.where(id: user&.id)
    end
  end
end
