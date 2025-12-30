# frozen_string_literal: true

module Admin
  module OrderStatuses
    class IndexPresenter
      attr_reader :order_statuses, :search_form

      def initialize(order_statuses:, search_form:)
        @order_statuses = order_statuses
        @search_form = search_form
      end

      def ordered_order_statuses
        @ordered_order_statuses ||= order_statuses.ordered
      end
    end
  end
end


