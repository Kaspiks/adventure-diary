# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Challenges", type: :request do
  let!(:started_status) { create(:attempt_status, :started) }
  let!(:challenge) { create(:challenge) }

  describe "GET /challenges" do
    context "when not authenticated" do
      it "redirects to sign in" do
        get challenges_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when authenticated" do
      let(:user) { create(:user, :general_user) }

      before { login_as(user, scope: :user) }

      it "returns success" do
        get challenges_path
        expect(response).to have_http_status(:ok)
      end

      it "shows active challenges" do
        active_challenge = create(:challenge, is_active: true, title: "Active Challenge")
        _inactive_challenge = create(:challenge, is_active: false, title: "Inactive Challenge")

        get challenges_path
        
        expect(response.body).to include("Active Challenge")
        expect(response.body).not_to include("Inactive Challenge")
      end
    end
  end

  describe "GET /challenges/:id" do
    context "when authenticated" do
      let(:user) { create(:user, :general_user) }

      before { login_as(user, scope: :user) }

      it "shows challenge details" do
        get challenge_path(challenge)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(challenge.title)
      end
    end
  end

  describe "POST /challenges/start_actions" do
    let(:user) { create(:user, :general_user) }

    before { login_as(user, scope: :user) }

    context "when challenge is active" do
      it "creates a new attempt" do
        expect {
          post challenges_start_actions_path, params: { challenge_id: challenge.id }
        }.to change(ChallengeAttempt, :count).by(1)
      end

      it "redirects to the new attempt" do
        post challenges_start_actions_path, params: { challenge_id: challenge.id }
        attempt = ChallengeAttempt.order(:id).last
        expect(response).to redirect_to(attempt_path(attempt))
      end

      it "sets correct attempt attributes" do
        post challenges_start_actions_path, params: { challenge_id: challenge.id }
        
        attempt = ChallengeAttempt.last
        expect(attempt.user).to eq(user)
        expect(attempt.challenge).to eq(challenge)
        expect(attempt.attempt_status.code).to eq("started")
        expect(attempt.started_at).to be_present
      end
    end

    context "when already has non-final attempt" do
      before do
        create(:challenge_attempt, user: user, challenge: challenge, attempt_status: started_status)
      end

      it "does not create new attempt" do
        expect {
          post challenges_start_actions_path, params: { challenge_id: challenge.id }
        }.not_to change(ChallengeAttempt, :count)
      end

      it "redirects with notice" do
        post challenges_start_actions_path, params: { challenge_id: challenge.id }
        expect(response).to redirect_to(my_attempts_path)
      end
    end

    context "when challenge is inactive" do
      let(:inactive_challenge) { create(:challenge, is_active: false) }

      it "denies access for general user" do
        post challenges_start_actions_path, params: { challenge_id: inactive_challenge.id }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
