# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :require_admin_access!

    layout "admin"

    private

    # Allow access for:
    # - Users with admin flag (full admin)
    # - Users with administrator role
    # - Users with company_user role (can manage their own challenges)
    def require_admin_access!
      return if current_user&.admin?
      return if current_user&.administrator?
      return if current_user&.company_user?

      flash[:alert] = t("admin.access_denied")
      redirect_to root_path
    end
  end
end
