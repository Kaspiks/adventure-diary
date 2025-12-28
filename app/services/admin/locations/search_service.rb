# frozen_string_literal: true

module Admin
  module Locations
    class SearchService
      def initialize(scope, params:)
        @scope = scope
        @params = params
      end

      def call
        scope = @scope

        scope = scope.name_matches(@params[:name]) if @params[:name].present?

        scope
      end
    end
  end
end

