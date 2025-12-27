# frozen_string_literal: true

require "rails_helper"

RSpec.describe ChallengeAttempt, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:challenge) }
    it { is_expected.to belong_to(:attempt_status) }
    it { is_expected.to belong_to(:reviewer_user).class_name("User").optional }
    it { is_expected.to have_many(:attempt_artifacts).dependent(:destroy) }
    it { is_expected.to have_many(:attempt_answers).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:started_at) }
    it { is_expected.to validate_length_of(:evidence_url).is_at_most(500) }
  end

  describe "status methods" do
    let(:started_status) { create(:attempt_status, :started) }
    let(:submitted_status) { create(:attempt_status, :submitted) }
    let(:approved_status) { create(:attempt_status, :approved) }
    let(:rejected_status) { create(:attempt_status, :rejected) }

    describe "#started?" do
      it "returns true when started" do
        attempt = create(:challenge_attempt, attempt_status: started_status)
        expect(attempt.started?).to be true
      end

      it "returns false otherwise" do
        attempt = create(:challenge_attempt, attempt_status: submitted_status)
        expect(attempt.started?).to be false
      end
    end

    describe "#submitted?" do
      it "returns true when submitted" do
        attempt = create(:challenge_attempt, attempt_status: submitted_status, submitted_at: Time.current)
        expect(attempt.submitted?).to be true
      end
    end

    describe "#approved?" do
      it "returns true when approved" do
        attempt = create(:challenge_attempt, :approved)
        expect(attempt.approved?).to be true
      end
    end

    describe "#rejected?" do
      it "returns true when rejected" do
        attempt = create(:challenge_attempt, :rejected)
        expect(attempt.rejected?).to be true
      end
    end

    describe "#final?" do
      it "returns true for approved" do
        attempt = create(:challenge_attempt, :approved)
        expect(attempt.final?).to be true
      end

      it "returns true for rejected" do
        attempt = create(:challenge_attempt, :rejected)
        expect(attempt.final?).to be true
      end

      it "returns false for started" do
        attempt = create(:challenge_attempt, attempt_status: started_status)
        expect(attempt.final?).to be false
      end
    end
  end

  describe "#can_submit?" do
    let(:started_status) { create(:attempt_status, :started) }
    let(:submitted_status) { create(:attempt_status, :submitted) }
    let(:approved_status) { create(:attempt_status, :approved) }

    it "returns true when started and not final" do
      attempt = create(:challenge_attempt, attempt_status: started_status)
      expect(attempt.can_submit?).to be true
    end

    it "returns false when submitted" do
      attempt = create(:challenge_attempt, attempt_status: submitted_status, submitted_at: Time.current)
      expect(attempt.can_submit?).to be false
    end

    it "returns false when final" do
      attempt = create(:challenge_attempt, :approved)
      expect(attempt.can_submit?).to be false
    end
  end

  describe "#can_review?" do
    let(:started_status) { create(:attempt_status, :started) }
    let(:submitted_status) { create(:attempt_status, :submitted) }
    let(:approved_status) { create(:attempt_status, :approved) }

    it "returns true when submitted and not final" do
      attempt = create(:challenge_attempt, attempt_status: submitted_status, submitted_at: Time.current)
      expect(attempt.can_review?).to be true
    end

    it "returns false when not submitted" do
      attempt = create(:challenge_attempt, attempt_status: started_status)
      expect(attempt.can_review?).to be false
    end

    it "returns false when final" do
      attempt = create(:challenge_attempt, :approved)
      expect(attempt.can_review?).to be false
    end
  end

  describe "#owned_by?" do
    let(:user) { create(:user, :general_user) }
    let(:other_user) { create(:user, :general_user) }
    let(:attempt) { create(:challenge_attempt, user: user) }

    it "returns true for owner" do
      expect(attempt.owned_by?(user)).to be true
    end

    it "returns false for others" do
      expect(attempt.owned_by?(other_user)).to be false
    end
  end

  describe "#calculate_score" do
    let(:challenge) { create(:challenge, :with_mixed_fields) }
    let(:attempt) { create(:challenge_attempt, challenge: challenge) }

    context "when no answers" do
      it "returns 0" do
        expect(attempt.calculate_score).to eq(0)
      end
    end

    context "when answers are correct" do
      before do
        challenge.fields.each do |field|
          create(:attempt_answer,
            challenge_attempt: attempt,
            field_id: field.id,
            is_correct: true
          )
        end
      end

      it "sums field points for correct answers" do
        expect(attempt.calculate_score).to eq(20)
      end
    end

    context "when some answers are incorrect" do
      before do
        fields = challenge.fields
        create(:attempt_answer,
          challenge_attempt: attempt,
          field_id: fields.first.id,
          is_correct: true
        )
        create(:attempt_answer,
          challenge_attempt: attempt,
          field_id: fields.last.id,
          is_correct: false
        )
      end

      it "only counts correct answers" do
        expect(attempt.calculate_score).to eq(10)
      end
    end
  end
end





