# frozen_string_literal: true

require "rails_helper"

RSpec.describe Challenge, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:creator_user).class_name("User") }
    it { is_expected.to belong_to(:location).optional }
    it { is_expected.to belong_to(:challenge_type) }
    it { is_expected.to belong_to(:difficulty_level) }
    it { is_expected.to belong_to(:award_point_level) }
    it { is_expected.to have_many(:challenge_attempts).dependent(:destroy) }
    it { is_expected.to have_many(:points_history).dependent(:nullify) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_most(255) }
  end

  describe "scopes" do
    let!(:active_challenge) { create(:challenge, is_active: true) }
    let!(:inactive_challenge) { create(:challenge, is_active: false) }

    describe ".active" do
      it "returns only active challenges" do
        expect(described_class.active).to include(active_challenge)
        expect(described_class.active).not_to include(inactive_challenge)
      end
    end

    describe ".inactive" do
      it "returns only inactive challenges" do
        expect(described_class.inactive).to include(inactive_challenge)
        expect(described_class.inactive).not_to include(active_challenge)
      end
    end
  end

  describe "#owned_by?" do
    let(:creator) { create(:user, :company_user) }
    let(:other_user) { create(:user, :company_user) }
    let(:challenge) { create(:challenge, creator_user: creator) }

    it "returns true for the creator" do
      expect(challenge.owned_by?(creator)).to be true
    end

    it "returns false for other users" do
      expect(challenge.owned_by?(other_user)).to be false
    end
  end

  describe "#award_points" do
    let(:award_level) { create(:award_point_level, points: 50) }
    let(:challenge) { create(:challenge, award_point_level: award_level) }

    it "returns points from award_point_level" do
      expect(challenge.award_points).to eq(50)
    end
  end

  describe "#fields" do
    context "with no fields" do
      let(:challenge) { create(:challenge, fields_config: []) }

      it "returns empty array" do
        expect(challenge.fields).to eq([])
      end
    end

    context "with fields configured" do
      let(:challenge) { create(:challenge, :with_text_field) }

      it "returns ChallengeField objects" do
        expect(challenge.fields.first).to be_a(ChallengeField)
        expect(challenge.fields.first.type).to eq("text_input")
      end
    end
  end

  describe "#quiz_challenge?" do
    let(:quiz_type) { create(:challenge_type, :quiz) }
    let(:photo_type) { create(:challenge_type, :photo) }

    it "returns true for quiz type" do
      challenge = create(:challenge, challenge_type: quiz_type)
      expect(challenge.quiz_challenge?).to be true
    end

    it "returns false for other types" do
      challenge = create(:challenge, challenge_type: photo_type)
      expect(challenge.quiz_challenge?).to be false
    end
  end

  describe "#has_fields?" do
    it "returns false when no fields" do
      challenge = create(:challenge, fields_config: [])
      expect(challenge.has_fields?).to be false
    end

    it "returns true when fields exist" do
      challenge = create(:challenge, :with_text_field)
      expect(challenge.has_fields?).to be true
    end
  end

  describe "#total_field_points" do
    let(:challenge) { create(:challenge, :with_mixed_fields) }

    it "sums all field points" do
      expect(challenge.total_field_points).to eq(20)
    end
  end
end


