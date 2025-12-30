# frozen_string_literal: true

require "rails_helper"

RSpec.describe Challenges::AwardPoints do
  let!(:approved_status) { create(:attempt_status, :approved) }
  let!(:started_status) { create(:attempt_status, :started) }
  let(:user) { create(:user, :general_user, reward_points: 0) }
  let(:challenge) { create(:challenge) }
  let(:attempt) do
    create(:challenge_attempt,
      user: user,
      challenge: challenge,
      attempt_status: approved_status,
      started_at: Time.current
    )
  end

  subject { described_class.new(attempt: attempt) }

  describe "#call" do
    context "with valid approved attempt" do
      it "returns a successful result" do
        result = subject.call
        expect(result).to be_success
      end

      it "awards points to user" do
        expected_points = challenge.award_points
        expect { subject.call }.to change { user.reload.reward_points }.by(expected_points)
      end

      it "creates points history entry" do
        expect { subject.call }.to change(PointsHistory, :count).by(1)
      end

      it "creates points history with correct values" do
        subject.call
        history = PointsHistory.last
        expect(history.delta_points).to eq(challenge.award_points)
        expect(history.reason_code).to eq("challenge_award")
        expect(history.challenge).to eq(challenge)
      end

      it "updates attempt score_awarded" do
        subject.call
        expect(attempt.reload.score_awarded).to eq(challenge.award_points)
      end
    end

    context "when points already awarded (idempotency)" do
      before do
        PointsHistory.create!(
          user: user,
          challenge: challenge,
          delta_points: challenge.award_points,
          reason_code: PointsHistory::REASON_CHALLENGE_AWARD
        )
      end

      it "returns a failure result" do
        result = subject.call
        expect(result).to be_failure
      end

      it "does not award points again" do
        expect { subject.call }.not_to(change { user.reload.reward_points })
      end

      it "includes error message" do
        result = subject.call
        expect(result.errors).to include("Points have already been awarded for this attempt")
      end
    end

    context "with non-approved attempt" do
      let(:attempt) do
        create(:challenge_attempt,
          user: user,
          challenge: challenge,
          attempt_status: started_status,
          started_at: Time.current
        )
      end

      it "returns a failure result" do
        result = subject.call
        expect(result).to be_failure
      end

      it "does not award points" do
        expect { subject.call }.not_to(change { user.reload.reward_points })
      end

      it "includes error message" do
        result = subject.call
        expect(result.errors).to include("Attempt must be approved")
      end
    end
  end
end

