# frozen_string_literal: true

module Admin
  class ClassificationValuePolicy < ApplicationPolicy
    def create?
      manage?
    end

    def update?
      manage?
    end

    private

    def manage?
      return false unless ClassificationPolicy.new(user, record.classification).update?

      can?("admin/classifications/manage")
    end
  end
end
