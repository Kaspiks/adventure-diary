# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :require_admin_access!

    layout "admin"

    helper_method :admin_navigation_presenter

    private

    def admin_navigation_presenter
      @admin_navigation_presenter ||= Admin::NavigationPresenter.new(
        view_context: view_context,
        controller_name: controller_name,
        user: current_user
      )
    end

    def require_admin_access!
      return if current_user&.admin?
      return if current_user&.administrator?
      return if current_user&.company_user?

      flash[:alert] = t("admin.access_denied")
      redirect_to root_path
    end
  end
end
