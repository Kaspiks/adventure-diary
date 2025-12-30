# frozen_string_literal: true

module Admin
  module AttemptStatuses
    class SearchService < ApplicationSearchService
      private

      def apply_filters
        filter_by_name
      end

      def filter_by_name
        return unless params[:name].present?

        @scope = @scope.where("name ILIKE ?", "%#{params[:name]}%")
      end
    end
  end
end


