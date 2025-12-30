# frozen_string_literal: true

module Admin
  module Orders
    class StatusActionsController < BaseController
      before_action :set_order

      def approve
        authorize @order, :update_status?
        transition_to("approved", t(".approved"))
      end

      def deliver
        authorize @order, :update_status?
        transition_to("delivered", t(".delivered"))
      end

      def cancel
        authorize @order, :update_status?
        transition_to("cancelled", t(".cancelled"))
      end

      private

      def set_order
        @order = Order.find(params[:id])
      end

      def transition_to(status_code, success_message)
        if @order.can_transition_to?(status_code)
          @order.transition_to!(status_code)
          redirect_back fallback_location: admin_order_path(@order), notice: success_message
        else
          redirect_back fallback_location: admin_order_path(@order), alert: t(".invalid_transition")
        end
      rescue StandardError => e
        redirect_back fallback_location: admin_order_path(@order), alert: e.message
      end
    end
  end
end

