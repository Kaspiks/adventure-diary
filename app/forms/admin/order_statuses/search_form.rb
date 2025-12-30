# frozen_string_literal: true

module Admin
  module OrderStatuses
    class SearchForm < ApplicationSearchForm
      attribute :name

      def search_performed?
        name.present?
      end
    end
  end
end


