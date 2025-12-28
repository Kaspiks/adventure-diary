# frozen_string_literal: true

module Admin
  class ClassificationItemPolicy < ApplicationPolicy
    def index?
      can?("admin/classifications/manage")
    end
  end
end
