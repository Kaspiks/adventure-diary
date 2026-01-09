# frozen_string_literal: true

module Admin
  class AttemptStatusPolicy < ApplicationPolicy
    def index?
      can?("attempt_statuses.index")
    end

    def new?
      can?("attempt_statuses.create")
    end

    def create?
      new?
    end

    def edit?
      can?("attempt_statuses.update")
    end

    def update?
      edit?
    end
  end
end

