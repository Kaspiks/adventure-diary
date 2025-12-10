# frozen_string_literal: true

module Admin
  module Users
    class ShowPresenter < ApplicationPresenter
      attr_reader :user, :current_user

      has_one_decorated :user, expose: true

      def initialize(user:, current_user:)
        super()
        @user = user
        @current_user = current_user
      end

      def admin_viewer?
        current_user&.admin?
      end

      def viewing_own_profile?
        current_user&.id == user.id
      end

      def can_edit?
        admin_viewer?
      end

      def can_delete?
        admin_viewer? && !viewing_own_profile?
      end

      def show_admin_info?
        admin_viewer?
      end
    end
  end
end
