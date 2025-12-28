# frozen_string_literal: true

module Admin
  module Locations
    class SearchForm < ApplicationSearchForm
      attribute :name, :string
    end
  end
end
