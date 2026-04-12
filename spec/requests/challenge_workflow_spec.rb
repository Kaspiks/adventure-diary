# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Challenge player workflow (request)", type: :request do
  let!(:started_status) { create(:attempt_status, :started) }
  let!(:submitted_status) { create(:attempt_status, :submitted) }
  let!(:approved_status) { create(:attempt_status, :approved) }
  let!(:rejected_status) { create(:attempt_status, :rejected) }

  let(:company_user) { create(:user, :company_user) }
  let(:general_user) { create(:user, :general_user, reward_points: 0) }
  let(:other_company) { create(:user, :company_user) }

  let(:challenge) do
    create(:challenge, :with_text_field, creator_user: company_user, is_active: true)
  end

  let(:inactive_challenge) { create(:challenge, :inactive, creator_user: company_user) }

  describe "discovery and details" do
    before { login_as(general_user, scope: :user) }

    it "lists active challenges (discover)" do
      active = create(:challenge, title: "Visible Trek", is_active: true, creator_user: company_user)
      _hidden = create(:challenge, title: "Hidden Trek", is_active: false, creator_user: company_user)

      get challenges_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(active.title)
      expect(response.body).not_to include("Hidden Trek")
    end

    it "opens challenge details" do
      get challenge_path(challenge)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(challenge.title)
    end
  end

  describe "starting a challenge" do
    before { login_as(general_user, scope: :user) }

    it "creates an attempt and redirects to the attempt" do
      expect do
        post challenges_start_actions_path, params: { challenge_id: challenge.id }
      end.to change(ChallengeAttempt, :count).by(1)

      attempt = ChallengeAttempt.order(:id).last
      expect(response).to redirect_to(attempt_path(attempt))
      follow_redirect!
      expect(response).to have_http_status(:ok)
    end

    it "does not allow a second non-final attempt for the same challenge" do
      create(:challenge_attempt, user: general_user, challenge: challenge, attempt_status: started_status)

      expect do
        post challenges_start_actions_path, params: { challenge_id: challenge.id }
      end.not_to change(ChallengeAttempt, :count)

      expect(response).to redirect_to(my_attempts_path)
    end

    it "blocks starting an inactive challenge for a general user" do
      post challenges_start_actions_path, params: { challenge_id: inactive_challenge.id }
      expect(response).to redirect_to(root_path)
    end
  end

  describe "submitting an attempt" do
    let(:attempt) do
      create(:challenge_attempt, user: general_user, challenge: challenge, attempt_status: started_status)
    end

    before { login_as(general_user, scope: :user) }

    it "accepts a valid submission and moves to submitted" do
      field_id = challenge.fields.first.id

      patch attempts_submit_action_path(attempt), params: {
        attempts_submit_actions_form: {
          answers: { field_id => "correct" }
        }
      }

      expect(response).to redirect_to(attempt_path(attempt))
      attempt.reload
      expect(attempt.submitted?).to be true
      expect(attempt.submitted_at).to be_present
    end

    it "rejects an invalid submission and keeps the attempt started" do
      field_id = challenge.fields.first.id

      patch attempts_submit_action_path(attempt), params: {
        attempts_submit_actions_form: {
          answers: { field_id => "" }
        }
      }

      expect(response).to redirect_to(attempt_path(attempt))
      expect(attempt.reload.started?).to be true
    end
  end

  describe "review and points" do
    let(:attempt) do
      create(:challenge_attempt,
        user: general_user,
        challenge: challenge,
        attempt_status: submitted_status,
        submitted_at: Time.current)
    end

    # Quiz challenges award only field scores (see Challenges::AwardPoints.calculate_points_for);
    # a submitted attempt without answers would award 0 points.
    before do
      field = challenge.template_fields.first
      attempt.attempt_answers.create!(
        field_id: field.id,
        answer_value: "correct",
        is_correct: true,
        answer_data: {}
      )
    end

    it "allows the challenge owner to approve and awards points once" do
      login_as(company_user, scope: :user)
      expected_award = Challenges::AwardPoints.calculate_points_for(attempt.reload)

      expect do
        post attempts_approve_action_path(attempt)
      end.to change { general_user.reload.reward_points }.by(expected_award)

      expect(attempt.reload.approved?).to be true
    end

    it "does not award points again if challenge_award history already exists" do
      PointsHistory.create!(
        user: general_user,
        challenge: challenge,
        delta_points: challenge.award_points,
        reason_code: PointsHistory::REASON_CHALLENGE_AWARD
      )
      general_user.update!(reward_points: challenge.award_points)

      login_as(company_user, scope: :user)

      expect do
        post attempts_approve_action_path(attempt)
      end.not_to(change { general_user.reload.reward_points })

      expect(attempt.reload.approved?).to be true
    end

    it "allows the challenge owner to reject without changing points balance" do
      login_as(company_user, scope: :user)
      balance_before = general_user.reward_points

      post attempts_reject_action_path(attempt)

      expect(attempt.reload.rejected?).to be true
      expect(general_user.reload.reward_points).to eq(balance_before)
    end

    it "denies review by a company user who does not own the challenge" do
      login_as(other_company, scope: :user)

      post attempts_approve_action_path(attempt)

      expect(response).to redirect_to(root_path)
      expect(attempt.reload.submitted?).to be true
    end
  end

  describe "admin approve (parallel path)" do
    let(:attempt) do
      create(:challenge_attempt,
        user: general_user,
        challenge: challenge,
        attempt_status: submitted_status,
        submitted_at: Time.current)
    end

    let(:admin) { create(:user, :admin) }

    it "approves via admin namespace" do
      login_as(admin, scope: :user)

      post admin_attempts_approve_action_path(attempt)

      expect(response).to redirect_to(admin_attempt_path(attempt))
      expect(attempt.reload.approved?).to be true
    end
  end
end
