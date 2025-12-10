# frozen_string_literal: true

module Admin
  module Users
    class SearchForm < ApplicationSearchForm
      attribute :first_name, :string
      attribute :last_name, :string
      attribute :email, :string
    end
  end
end
