# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Orders", type: :request do
  let!(:pending_status) { create(:order_status, :pending) }
  let!(:approved_status) { create(:order_status, :approved) }
  let!(:delivered_status) { create(:order_status, :delivered) }
  let!(:cancelled_status) { create(:order_status, :cancelled) }

  let(:company_user) { create(:user, :company_user) }
  let(:buyer) { create(:user, :general_user) }
  let(:reward) { create(:reward, owner_user: company_user) }
  let!(:order) { create(:order, user: buyer, reward: reward, order_status: pending_status) }

  describe "GET /admin/orders" do
    context "when authenticated as reward owner" do
      before { sign_in company_user }

      it "returns success" do
        get admin_orders_path
        expect(response).to have_http_status(:ok)
      end

      it "shows orders for owned rewards" do
        get admin_orders_path
        expect(response.body).to include(buyer.full_name)
      end
    end
  end

  describe "POST /admin/orders/status_actions/:id/approve" do
    before { sign_in company_user }

    it "approves the order" do
      post admin_orders_status_action_approve_path(order.id)
      expect(order.reload.order_status.code).to eq("approved")
    end

    it "redirects with success message" do
      post admin_orders_status_action_approve_path(order.id)
      expect(response).to redirect_to(admin_order_path(order))
      expect(flash[:notice]).to be_present
    end
  end

  describe "POST /admin/orders/status_actions/:id/deliver" do
    before do
      order.update!(order_status: approved_status)
      sign_in company_user
    end

    it "marks order as delivered" do
      post admin_orders_status_action_deliver_path(order.id)
      expect(order.reload.order_status.code).to eq("delivered")
    end
  end

  describe "POST /admin/orders/status_actions/:id/cancel" do
    before { sign_in company_user }

    it "cancels the order" do
      post admin_orders_status_action_cancel_path(order.id)
      expect(order.reload.order_status.code).to eq("cancelled")
    end
  end

  describe "authorization" do
    let(:other_company_user) { create(:user, :company_user) }

    before { sign_in other_company_user }

    it "denies status change for non-owner" do
      post admin_orders_status_action_approve_path(order.id)
      expect(response).to redirect_to(root_path)
    end
  end
end

