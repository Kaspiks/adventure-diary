# frozen_string_literal: true

module Admin
  module Challenges
    class IndexPresenter < ApplicationPresenter
      attr_reader :search_form, :challenges

      has_many_decorated :challenges, expose: true

      def initialize(search_form:, challenges:)
        super()
        @search_form = search_form
        @challenges = challenges
      end

      def total_count
        challenges.count
      end
    end
  end
end






