# frozen_string_literal: true

module Admin
  module Challenges
    class SearchForm < ApplicationSearchForm
      attribute :title, :string
      attribute :is_active, :string
    end
  end
end






