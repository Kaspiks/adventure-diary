# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Rewards", type: :request do
  let(:company_user) { create(:user, :company_user) }
  let!(:reward) { create(:reward, owner_user: company_user) }

  describe "GET /admin/rewards" do
    context "when authenticated as company user" do
      before { login_as(company_user, scope: :user) }

      it "returns success" do
        get admin_rewards_path
        expect(response).to have_http_status(:ok)
      end

      it "shows owned rewards" do
        get admin_rewards_path
        expect(response.body).to include(reward.title)
      end
    end

    context "when authenticated as general user" do
      let(:general_user) { create(:user, :general_user) }

      before { login_as(general_user, scope: :user) }

      it "denies access" do
        get admin_rewards_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /admin/rewards" do
    before { login_as(company_user, scope: :user) }

    let(:valid_params) do
      {
        admin_rewards_form: {
          title: "New Reward",
          description: "Reward description",
          cost_points: 200,
          is_active: true,
          stock_quantity: 10
        }
      }
    end

    it "creates a new reward" do
      expect {
        post admin_rewards_path, params: valid_params
      }.to change(Reward, :count).by(1)
    end

    it "assigns current user as owner" do
      post admin_rewards_path, params: valid_params
      expect(Reward.last.owner_user).to eq(company_user)
    end

    it "redirects to show page" do
      post admin_rewards_path, params: valid_params
      expect(response).to redirect_to(admin_reward_path(Reward.last))
    end
  end

  describe "PATCH /admin/rewards/:id" do
    before { login_as(company_user, scope: :user) }

    it "updates the reward" do
      patch admin_reward_path(reward), params: { admin_rewards_form: { title: "Updated Title" } }
      expect(reward.reload.title).to eq("Updated Title")
    end

    context "when trying to update another user's reward" do
      let(:other_company_user) { create(:user, :company_user) }

      before { login_as(other_company_user, scope: :user) }

      it "denies access" do
        patch admin_reward_path(reward), params: { admin_rewards_form: { title: "Hacked" } }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE /admin/rewards/:id" do
    before { login_as(company_user, scope: :user) }

    it "deletes the reward" do
      expect {
        delete admin_reward_path(reward)
      }.to change(Reward, :count).by(-1)
    end
  end
end

