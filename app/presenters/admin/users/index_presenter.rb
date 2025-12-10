# frozen_string_literal: true

module Admin
  module Users
    class IndexPresenter < ApplicationPresenter
      attr_reader :search_form, :users

      has_many_decorated :users, expose: true

      def initialize(search_form:, users:)
        super()
        @search_form = search_form
        @users = users
      end

      def total_count
        users.count
      end
    end
  end
end
