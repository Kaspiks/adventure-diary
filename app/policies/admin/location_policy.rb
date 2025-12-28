# frozen_string_literal: true

module Admin
  class LocationPolicy < ApplicationPolicy
    def index?
      can?("locations.index")
    end

    def create?
      can?("locations.create")
    end

    def update?
      can?("locations.update")
    end
  end
end

