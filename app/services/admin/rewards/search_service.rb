# frozen_string_literal: true

module Admin
  module Rewards
    class SearchService
      attr_reader :search_form, :current_user, :sortable_params

      def initialize(search_form:, current_user:, sortable_params: {})
        @search_form = search_form
        @current_user = current_user
        @sortable_params = sortable_params
      end

      def call
        scope = base_scope

        scope = scope.title_matches(search_form.title) if search_form.title.present?
        scope = apply_active_filter(scope) if search_form.is_active.present?

        scope = scope.includes(:owner_user)

        if sortable_params[:sort].present?
          scope.sorted(sortable_params)
        else
          scope.order(created_at: :desc)
        end
      end

      private

      def base_scope
        if current_user.administrator? || current_user.admin?
          Reward.all
        elsif current_user.company_user?
          Reward.by_owner(current_user)
        else
          Reward.none
        end
      end

      def apply_active_filter(scope)
        case search_form.is_active
        when "true"
          scope.active
        when "false"
          scope.inactive
        else
          scope
        end
      end
    end
  end
end

