# frozen_string_literal: true

module Admin
  module Rewards
    class IndexPresenter < ApplicationPresenter
      attr_reader :search_form, :rewards

      has_many_decorated :rewards, expose: true

      def initialize(
        search_form:, 
        rewards:,
        sortable_params:
      )
        super()
        @search_form = search_form
        @rewards = rewards
        @sortable_params = sortable_params
      end

      def total_count
        rewards.count
      end
    end
  end
end

