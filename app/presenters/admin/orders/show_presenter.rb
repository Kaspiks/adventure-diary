# frozen_string_literal: true

module Admin
  module Orders
    class ShowPresenter < ApplicationPresenter
      attr_reader :order

      has_one_decorated :order, expose: true

      def initialize(order:)
        super()
        @order = order
      end
    end
  end
end

