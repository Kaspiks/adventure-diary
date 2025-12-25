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

      before { sign_in user }

      it "returns success" do
        get challenges_path
        expect(response).to have_http_status(:ok)
      end

      it "shows active challenges" do
        active_challenge = create(:challenge, is_active: true, title: "Active Challenge")
        inactive_challenge = create(:challenge, is_active: false, title: "Inactive Challenge")

        get challenges_path
        
        expect(response.body).to include("Active Challenge")
        expect(response.body).not_to include("Inactive Challenge")
      end
    end
  end

  describe "GET /challenges/:id" do
    context "when authenticated" do
      let(:user) { create(:user, :general_user) }

      before { sign_in user }

      it "shows challenge details" do
        get challenge_path(challenge)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(challenge.title)
      end
    end
  end

  describe "POST /challenges/:id/start" do
    let(:user) { create(:user, :general_user) }

    before { sign_in user }

    context "when challenge is active" do
      it "creates a new attempt" do
        expect {
          post start_challenge_path(challenge)
        }.to change(ChallengeAttempt, :count).by(1)
      end

      it "redirects to my attempts" do
        post start_challenge_path(challenge)
        expect(response).to redirect_to(my_attempts_path)
      end

      it "sets correct attempt attributes" do
        post start_challenge_path(challenge)
        
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
          post start_challenge_path(challenge)
        }.not_to change(ChallengeAttempt, :count)
      end

      it "redirects with notice" do
        post start_challenge_path(challenge)
        expect(response).to redirect_to(my_attempts_path)
      end
    end

    context "when challenge is inactive" do
      let(:inactive_challenge) { create(:challenge, is_active: false) }

      it "denies access for general user" do
        post start_challenge_path(inactive_challenge)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end

