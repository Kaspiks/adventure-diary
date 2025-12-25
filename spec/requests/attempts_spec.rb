# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Attempts", type: :request do
  let!(:started_status) { create(:attempt_status, :started) }
  let!(:submitted_status) { create(:attempt_status, :submitted) }
  let!(:approved_status) { create(:attempt_status, :approved) }
  let!(:rejected_status) { create(:attempt_status, :rejected) }

  describe "GET /my/attempts" do
    context "when authenticated" do
      let(:user) { create(:user, :general_user) }

      before { sign_in user }

      it "returns success" do
        get my_attempts_path
        expect(response).to have_http_status(:ok)
      end

      it "shows only user's attempts" do
        user_attempt = create(:challenge_attempt, user: user, attempt_status: started_status)
        other_attempt = create(:challenge_attempt, attempt_status: started_status)

        get my_attempts_path

        expect(response.body).to include(user_attempt.challenge.title)
      end
    end
  end

  describe "PATCH /attempts/:id/submit" do
    let(:user) { create(:user, :general_user) }
    let(:challenge) { create(:challenge) }
    let(:attempt) { create(:challenge_attempt, user: user, challenge: challenge, attempt_status: started_status) }

    before { sign_in user }

    context "when owner submits" do
      it "changes status to submitted" do
        patch submit_attempt_path(attempt), params: { evidence_url: "https://example.com/photo.jpg" }
        
        attempt.reload
        expect(attempt.submitted?).to be true
        expect(attempt.submitted_at).to be_present
      end

      it "redirects to my attempts" do
        patch submit_attempt_path(attempt), params: { evidence_url: "https://example.com/photo.jpg" }
        expect(response).to redirect_to(my_attempts_path)
      end
    end

    context "when not owner" do
      let(:other_user) { create(:user, :general_user) }

      before { sign_in other_user }

      it "denies access" do
        patch submit_attempt_path(attempt), params: { evidence_url: "https://example.com/photo.jpg" }
        expect(response).to redirect_to(root_path)
      end
    end

    context "when attempt is already final" do
      let(:final_attempt) { create(:challenge_attempt, :approved, user: user, challenge: challenge) }

      it "denies submission" do
        patch submit_attempt_path(final_attempt), params: { evidence_url: "https://example.com/photo.jpg" }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /attempts/:id/approve" do
    let(:company_user) { create(:user, :company_user) }
    let(:challenge) { create(:challenge, creator_user: company_user) }
    let(:general_user) { create(:user, :general_user, reward_points: 0) }
    let(:attempt) do
      create(:challenge_attempt,
        user: general_user,
        challenge: challenge,
        attempt_status: submitted_status,
        submitted_at: Time.current
      )
    end

    context "when challenge owner approves" do
      before { sign_in company_user }

      it "changes status to approved" do
        post approve_attempt_path(attempt)
        
        attempt.reload
        expect(attempt.approved?).to be true
        expect(attempt.reviewed_at).to be_present
        expect(attempt.reviewer_user).to eq(company_user)
      end

      it "awards points to user" do
        post approve_attempt_path(attempt)
        
        general_user.reload
        expect(general_user.reward_points).to eq(challenge.award_points)
      end

      it "creates points_history entry" do
        expect {
          post approve_attempt_path(attempt)
        }.to change(PointsHistory, :count).by(1)
      end

      it "is idempotent - does not double award" do
        # First approval
        post approve_attempt_path(attempt)
        initial_points = general_user.reload.reward_points

        # Try to approve again (simulate re-submission)
        # This should not create another points_history entry
        # because the attempt is already final
        post approve_attempt_path(attempt)
        
        expect(general_user.reload.reward_points).to eq(initial_points)
      end
    end

    context "when not challenge owner" do
      let(:other_company_user) { create(:user, :company_user) }

      before { sign_in other_company_user }

      it "denies access" do
        post approve_attempt_path(attempt)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when administrator" do
      let(:admin) { create(:user, :admin) }

      before { sign_in admin }

      it "can approve any attempt" do
        post approve_attempt_path(attempt)
        
        attempt.reload
        expect(attempt.approved?).to be true
      end
    end
  end

  describe "POST /attempts/:id/reject" do
    let(:company_user) { create(:user, :company_user) }
    let(:challenge) { create(:challenge, creator_user: company_user) }
    let(:general_user) { create(:user, :general_user, reward_points: 100) }
    let(:attempt) do
      create(:challenge_attempt,
        user: general_user,
        challenge: challenge,
        attempt_status: submitted_status,
        submitted_at: Time.current
      )
    end

    before { sign_in company_user }

    it "changes status to rejected" do
      post reject_attempt_path(attempt)
      
      attempt.reload
      expect(attempt.rejected?).to be true
      expect(attempt.reviewed_at).to be_present
      expect(attempt.reviewer_user).to eq(company_user)
      expect(attempt.score_awarded).to eq(0)
    end

    it "does not award points" do
      initial_points = general_user.reward_points
      
      post reject_attempt_path(attempt)
      
      expect(general_user.reload.reward_points).to eq(initial_points)
    end

    it "does not create points_history entry" do
      expect {
        post reject_attempt_path(attempt)
      }.not_to change(PointsHistory, :count)
    end
  end
end

