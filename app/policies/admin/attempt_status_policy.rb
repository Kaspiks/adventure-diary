# frozen_string_literal: true

module Admin
  class AttemptStatusPolicy < ApplicationPolicy
    def index?
      user_has_permission?("attempt_statuses.index")
    end

    def new?
      user_has_permission?("attempt_statuses.create")
    end

    def create?
      new?
    end

    def edit?
      user_has_permission?("attempt_statuses.update")
    end

    def update?
      edit?
    end
  end
end

