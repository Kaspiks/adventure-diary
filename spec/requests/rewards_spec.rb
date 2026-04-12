# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Rewards", type: :request do
  let!(:pending_status) { create(:order_status, :pending) }
  let(:company_user) { create(:user, :company_user) }
  let!(:reward) { create(:reward, owner_user: company_user, cost_points: 100, is_active: true) }

  describe "GET /rewards" do
    context "when not authenticated" do
      it "redirects to sign in" do
        get rewards_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      let(:user) { create(:user, :general_user) }

      before { login_as(user, scope: :user) }

      it "returns success" do
        get rewards_path
        expect(response).to have_http_status(:ok)
      end

      it "shows active rewards" do
        active_reward = create(:reward, owner_user: company_user, is_active: true, title: "Active Reward")
        _inactive_reward = create(:reward, owner_user: company_user, is_active: false, title: "Inactive Reward")

        get rewards_path

        expect(response.body).to include("Active Reward")
        expect(response.body).not_to include("Inactive Reward")
      end
    end
  end

  describe "GET /rewards/:id" do
    context "when authenticated" do
      let(:user) { create(:user, :general_user) }

      before { login_as(user, scope: :user) }

      it "shows reward details" do
        get reward_path(reward)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(reward.title)
      end
    end
  end

  describe "POST /rewards/purchase_actions/:reward_id" do
    let(:user) { create(:user, :general_user, reward_points: 500) }

    before { login_as(user, scope: :user) }

    context "with sufficient points" do
      it "creates an order" do
        expect {
          post rewards_purchase_actions_path(reward_id: reward.id)
        }.to change(Order, :count).by(1)
      end

      it "redirects to order page" do
        post rewards_purchase_actions_path(reward_id: reward.id)
        expect(response).to redirect_to(order_path(Order.last))
      end

      it "deducts points from user" do
        expect {
          post rewards_purchase_actions_path(reward_id: reward.id)
        }.to change { user.reload.reward_points }.by(-100)
      end
    end

    context "with insufficient points" do
      let(:user) { create(:user, :general_user, reward_points: 50) }

      it "does not create an order" do
        expect {
          post rewards_purchase_actions_path(reward_id: reward.id)
        }.not_to change(Order, :count)
      end

      it "redirects with alert" do
        post rewards_purchase_actions_path(reward_id: reward.id)
        # Pundit denies access when user can't afford, redirects to root
        expect(response).to redirect_to(root_path)
      end
    end

    context "with inactive reward" do
      let(:reward) { create(:reward, :inactive, owner_user: company_user, cost_points: 100) }

      it "denies access" do
        post rewards_purchase_actions_path(reward_id: reward.id)
        expect(response).to redirect_to(root_path)
      end
    end

    context "with out of stock reward" do
      let(:reward) { create(:reward, :out_of_stock, owner_user: company_user, cost_points: 100) }

      it "denies access" do
        post rewards_purchase_actions_path(reward_id: reward.id)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end

