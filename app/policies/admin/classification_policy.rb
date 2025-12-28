# frozen_string_literal: true

module Admin
  class ClassificationPolicy < ApplicationPolicy
    def update?
      return false if record.respond_to?(:system?) && record.system?

      can?("admin/classifications/manage")
    end

    def show?
      can?("admin/classifications/manage")
    end
  end
end
