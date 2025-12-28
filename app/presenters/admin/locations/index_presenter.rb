# frozen_string_literal: true

module Admin
  module Locations
    class IndexPresenter < ApplicationPresenter
      attr_reader :search_form

      def initialize(locations:, search_form:)
        super()
        @locations = locations
        @search_form = search_form
      end

      def ordered_locations
        decorate_collection(@locations.order(:name, :id))
      end
    end
  end
end
