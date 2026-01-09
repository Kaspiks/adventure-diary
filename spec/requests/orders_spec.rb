# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Orders", type: :request do
  let!(:pending_status) { create(:order_status, :pending) }
  let(:user) { create(:user, :general_user) }
  let(:company_user) { create(:user, :company_user) }
  let(:reward) { create(:reward, owner_user: company_user) }
  let!(:order) { create(:order, user: user, reward: reward, order_status: pending_status) }

  describe "GET /orders" do
    context "when not authenticated" do
      it "redirects to sign in" do
        get orders_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      before { sign_in user }

      it "returns success" do
        get orders_path
        expect(response).to have_http_status(:ok)
      end

      it "shows user's own orders" do
        get orders_path
        expect(response.body).to include(reward.title)
      end

      it "does not show other users' orders" do
        other_user = create(:user, :general_user)
        other_order = create(:order, user: other_user, reward: reward, order_status: pending_status)

        sign_in user
        get orders_path

        # Check that links to other user's orders don't appear
        expect(response.body).not_to include(order_path(other_order))
      end
    end
  end

  describe "GET /orders/:id" do
    context "when authenticated as order owner" do
      before { sign_in user }

      it "shows order details" do
        get order_path(order)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when authenticated as reward owner" do
      before { sign_in company_user }

      it "shows order details" do
        get order_path(order)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when authenticated as different user" do
      let(:other_user) { create(:user, :general_user) }

      before { sign_in other_user }

      it "denies access" do
        get order_path(order)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end

