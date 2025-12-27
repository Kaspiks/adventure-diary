# frozen_string_literal: true

class SettingPolicy < ApplicationPolicy
  def index? = can?("settings.view")
  def show? = can?("settings.view")
  def update? = can?("settings.update")

  class Scope < ApplicationPolicy::Scope
    def resolve
      can?("settings.view") ? scope.all : scope.none
    end
  end
end










