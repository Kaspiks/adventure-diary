# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:role).optional }
    it { is_expected.to have_many(:created_challenges).class_name("Challenge").dependent(:restrict_with_error) }
    it { is_expected.to have_many(:challenge_attempts).dependent(:destroy) }
    it { is_expected.to have_many(:reviewed_attempts).class_name("ChallengeAttempt").dependent(:nullify) }
    it { is_expected.to have_many(:points_history).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_length_of(:first_name).is_at_most(255) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(255) }
    it { is_expected.to validate_presence_of(:email) }
  end

  describe "role methods" do
    describe "#administrator?" do
      it "returns true for admin flag" do
        user = create(:user, admin: true)
        expect(user.administrator?).to be true
      end

      it "returns true for administrator role" do
        user = create(:user, :administrator)
        expect(user.administrator?).to be true
      end

      it "returns false for other roles" do
        user = create(:user, :company_user)
        expect(user.administrator?).to be false
      end
    end

    describe "#company_user?" do
      it "returns true for company_user role" do
        user = create(:user, :company_user)
        expect(user.company_user?).to be true
      end

      it "returns false for other roles" do
        user = create(:user, :general_user)
        expect(user.company_user?).to be false
      end
    end

    describe "#general_user?" do
      it "returns true for general_user role" do
        user = create(:user, :general_user)
        expect(user.general_user?).to be true
      end

      it "returns false for other roles" do
        user = create(:user, :company_user)
        expect(user.general_user?).to be false
      end
    end
  end

  describe "#can_create_challenges?" do
    it "returns true for administrators" do
      user = create(:user, :administrator)
      expect(user.can_create_challenges?).to be true
    end

    it "returns true for company_users" do
      user = create(:user, :company_user)
      expect(user.can_create_challenges?).to be true
    end

    it "returns false for general_users" do
      user = create(:user, :general_user)
      expect(user.can_create_challenges?).to be false
    end
  end

  describe "#can_review_attempts?" do
    it "returns true for administrators" do
      user = create(:user, :administrator)
      expect(user.can_review_attempts?).to be true
    end

    it "returns true for company_users" do
      user = create(:user, :company_user)
      expect(user.can_review_attempts?).to be true
    end

    it "returns false for general_users" do
      user = create(:user, :general_user)
      expect(user.can_review_attempts?).to be false
    end
  end

  describe "#add_points!" do
    let(:user) { create(:user, :general_user, reward_points: 100) }
    let(:challenge) { create(:challenge) }

    it "increments reward_points" do
      expect {
        user.add_points!(50, reason_code: "challenge_award", challenge: challenge)
      }.to change { user.reload.reward_points }.from(100).to(150)
    end

    it "creates points_history entry" do
      expect {
        user.add_points!(50, reason_code: "challenge_award", challenge: challenge)
      }.to change { user.points_history.count }.by(1)
    end

    it "sets correct attributes on points_history" do
      user.add_points!(50, reason_code: "challenge_award", challenge: challenge)
      
      history = user.points_history.last
      expect(history.delta_points).to eq(50)
      expect(history.reason_code).to eq("challenge_award")
      expect(history.challenge).to eq(challenge)
    end
  end

  describe "#full_name" do
    let(:user) { build(:user, first_name: "John", last_name: "Doe") }

    it "combines first and last name" do
      expect(user.full_name).to eq("John Doe")
    end
  end

  describe "#active_for_authentication?" do
    it "returns false when blocked" do
      user = create(:user, blocked: true)
      expect(user.active_for_authentication?).to be false
    end

    it "returns true when not blocked" do
      user = create(:user, blocked: false)
      expect(user.active_for_authentication?).to be true
    end
  end
end





