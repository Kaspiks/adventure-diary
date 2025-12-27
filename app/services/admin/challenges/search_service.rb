# frozen_string_literal: true

module Admin
  module Challenges
    class SearchService
      attr_reader :search_form, :current_user

      def initialize(search_form:, current_user:)
        @search_form = search_form
        @current_user = current_user
      end

      def call
        scope = base_scope

        scope = scope.title_matches(search_form.title) if search_form.title.present?
        scope = apply_active_filter(scope) if search_form.is_active.present?

        scope.includes(:challenge_type, :difficulty_level, :award_point_level, :location, :creator_user)
             .order(created_at: :desc)
      end

      private

      def base_scope
        if current_user.administrator?
          Challenge.all
        elsif current_user.company_user?
          Challenge.by_creator(current_user)
        else
          Challenge.none
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







