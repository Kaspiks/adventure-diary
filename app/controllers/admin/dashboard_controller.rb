# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def index
      @presenter = Admin::Dashboards::IndexPresenter.new(current_user: current_user)
    end
  end
end
