# frozen_string_literal: true

module Admin
  module Users
    class SearchService
      attr_reader :search_form

      def initialize(search_form:)
        @search_form = search_form
      end

      def call
        scope = User.all

        scope = scope.first_name_matches(search_form.first_name) if search_form.first_name.present?
        scope = scope.last_name_matches(search_form.last_name) if search_form.last_name.present?
        scope = scope.email_matches(search_form.email) if search_form.email.present?

        scope.order(created_at: :desc)
      end
    end
  end
end
