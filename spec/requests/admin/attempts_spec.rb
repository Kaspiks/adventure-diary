# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Attempts", type: :request do
  let!(:started_status) { create(:attempt_status, :started) }
  let!(:submitted_status) { create(:attempt_status, :submitted) }
  let!(:approved_status) { create(:attempt_status, :approved) }
  let!(:rejected_status) { create(:attempt_status, :rejected) }

  let(:company_user) { create(:user, :company_user) }
  let(:challenge) { create(:challenge, creator_user: company_user) }
  let(:general_user) { create(:user, :general_user, reward_points: 0) }

  describe "POST /admin/attempts/:id/approve" do
    let(:attempt) do
      create(:challenge_attempt,
        user: general_user,
        challenge: challenge,
        attempt_status: submitted_status,
        submitted_at: Time.current
      )
    end

    context "when admin user" do
      let(:admin) { create(:user, :admin) }

      before { sign_in admin }

      it "approves attempt" do
        post approve_admin_attempt_path(attempt)
        
        attempt.reload
        expect(attempt.approved?).to be true
      end

      it "awards points" do
        post approve_admin_attempt_path(attempt)
        
        general_user.reload
        expect(general_user.reward_points).to eq(challenge.award_points)
      end

      it "creates points_history" do
        expect {
          post approve_admin_attempt_path(attempt)
        }.to change(PointsHistory, :count).by(1)
      end

      it "sets reviewer" do
        post approve_admin_attempt_path(attempt)
        
        attempt.reload
        expect(attempt.reviewer_user).to eq(admin)
      end
    end

    context "when company_user owns challenge" do
      before { sign_in company_user }

      it "can approve" do
        post approve_admin_attempt_path(attempt)
        
        attempt.reload
        expect(attempt.approved?).to be true
      end
    end

    context "when company_user does not own challenge" do
      let(:other_company) { create(:user, :company_user) }

      before { sign_in other_company }

      it "denies access" do
        post approve_admin_attempt_path(attempt)
        expect(response).to redirect_to(root_path)
      end
    end

    context "with quiz challenge and field scoring" do
      let(:quiz_type) { create(:challenge_type, :quiz) }
      let(:quiz_challenge) do
        create(:challenge,
          creator_user: company_user,
          challenge_type: quiz_type,
          :with_mixed_fields
        )
      end
      let(:quiz_attempt) do
        create(:challenge_attempt,
          user: general_user,
          challenge: quiz_challenge,
          attempt_status: submitted_status,
          submitted_at: Time.current
        )
      end

      before do
        sign_in company_user
        # Create correct answers for all fields
        quiz_challenge.fields.each do |field|
          create(:attempt_answer,
            challenge_attempt: quiz_attempt,
            field_id: field.id,
            is_correct: true
          )
        end
      end

      it "uses field-based scoring for quiz" do
        post approve_admin_attempt_path(quiz_attempt)
        
        quiz_attempt.reload
        # Mixed fields have 10 + 10 = 20 points total
        expect(quiz_attempt.score_awarded).to eq(20)
      end

      it "awards field-based points to user" do
        post approve_admin_attempt_path(quiz_attempt)
        
        general_user.reload
        expect(general_user.reward_points).to eq(20)
      end
    end

    context "idempotent approval" do
      before { sign_in company_user }

      it "does not double award points" do
        # First approval
        post approve_admin_attempt_path(attempt)
        initial_points = general_user.reload.reward_points
        initial_history_count = PointsHistory.count

        # Simulate trying to approve again (would be blocked by final check)
        post approve_admin_attempt_path(attempt)

        expect(general_user.reload.reward_points).to eq(initial_points)
        expect(PointsHistory.count).to eq(initial_history_count)
      end
    end
  end

  describe "POST /admin/attempts/:id/reject" do
    let(:attempt) do
      create(:challenge_attempt,
        user: general_user,
        challenge: challenge,
        attempt_status: submitted_status,
        submitted_at: Time.current
      )
    end

    context "when admin" do
      let(:admin) { create(:user, :admin) }

      before { sign_in admin }

      it "rejects attempt" do
        post reject_admin_attempt_path(attempt)
        
        attempt.reload
        expect(attempt.rejected?).to be true
        expect(attempt.score_awarded).to eq(0)
      end

      it "does not award points" do
        initial_points = general_user.reward_points
        
        post reject_admin_attempt_path(attempt)
        
        expect(general_user.reload.reward_points).to eq(initial_points)
      end
    end
  end

  describe "access control" do
    let(:attempt) do
      create(:challenge_attempt,
        user: general_user,
        challenge: challenge,
        attempt_status: submitted_status,
        submitted_at: Time.current
      )
    end

    context "when general_user" do
      before { sign_in general_user }

      it "denies access to admin attempts" do
        get admin_attempts_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when not authenticated" do
      it "redirects to sign in" do
        get admin_attempts_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end

