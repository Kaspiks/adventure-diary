# frozen_string_literal: true

require "rails_helper"

RSpec.describe ChallengeDecorator do
  describe "#status_badge" do
    context "when challenge is active" do
      it "returns 'Active'" do
        instance = decorated_instance_double(Challenge, is_active: true)

        expect(instance.status_badge).to eq "Active"
      end
    end

    context "when challenge is inactive" do
      it "returns 'Inactive'" do
        instance = decorated_instance_double(Challenge, is_active: false)

        expect(instance.status_badge).to eq "Inactive"
      end
    end
  end

  describe "#status_color" do
    context "when challenge is active" do
      it "returns 'emerald'" do
        instance = decorated_instance_double(Challenge, is_active: true)

        expect(instance.status_color).to eq "emerald"
      end
    end

    context "when challenge is inactive" do
      it "returns 'slate'" do
        instance = decorated_instance_double(Challenge, is_active: false)

        expect(instance.status_color).to eq "slate"
      end
    end
  end

  describe "#type_name" do
    it "returns the challenge type name" do
      challenge_type = double("ChallengeType", name: "Photo Challenge")
      instance = decorated_instance_double(Challenge, challenge_type: challenge_type)

      expect(instance.type_name).to eq "Photo Challenge"
    end

    context "when challenge type is nil" do
      it "returns nil" do
        instance = decorated_instance_double(Challenge, challenge_type: nil)

        expect(instance.type_name).to be_nil
      end
    end
  end

  describe "#difficulty_name" do
    it "returns the difficulty level name" do
      difficulty = double("DifficultyLevel", name: "Easy")
      instance = decorated_instance_double(Challenge, difficulty_level: difficulty)

      expect(instance.difficulty_name).to eq "Easy"
    end

    context "when difficulty level is nil" do
      it "returns nil" do
        instance = decorated_instance_double(Challenge, difficulty_level: nil)

        expect(instance.difficulty_name).to be_nil
      end
    end
  end

  describe "#points" do
    it "returns the award points" do
      award_level = double("AwardPointLevel", points: 100)
      instance = decorated_instance_double(Challenge, award_point_level: award_level)

      expect(instance.points).to eq 100
    end

    context "when award point level is nil" do
      it "returns 0" do
        instance = decorated_instance_double(Challenge, award_point_level: nil)

        expect(instance.points).to eq 0
      end
    end
  end

  describe "#points_display" do
    it "returns formatted points string" do
      award_level = double("AwardPointLevel", points: 100)
      instance = decorated_instance_double(Challenge, award_point_level: award_level)

      expect(instance.points_display).to eq "100 pts"
    end
  end

  describe "#location_name" do
    it "returns the location name" do
      location = double("Location", name: "Central Park")
      instance = decorated_instance_double(Challenge, location: location)

      expect(instance.location_name).to eq "Central Park"
    end

    context "when location is nil" do
      it "returns 'Any Location'" do
        instance = decorated_instance_double(Challenge, location: nil)

        expect(instance.location_name).to eq "Any Location"
      end
    end
  end

  describe "#creator_name" do
    it "returns the creator's full name" do
      creator = double("User", full_name: "Jane Doe")
      instance = decorated_instance_double(Challenge, creator_user: creator)

      expect(instance.creator_name).to eq "Jane Doe"
    end

    context "when creator is nil" do
      it "returns nil" do
        instance = decorated_instance_double(Challenge, creator_user: nil)

        expect(instance.creator_name).to be_nil
      end
    end
  end

  describe "#attempts_count" do
    it "returns the count of challenge attempts" do
      attempts = double("attempts", count: 5)
      instance = decorated_instance_double(Challenge, challenge_attempts: attempts)

      expect(instance.attempts_count).to eq 5
    end
  end

  describe "#pending_attempts_count" do
    it "returns the count of pending review attempts" do
      pending_scope = double("pending_scope", count: 2)
      attempts = double("attempts", pending_review: pending_scope)
      instance = decorated_instance_double(Challenge, challenge_attempts: attempts)

      expect(instance.pending_attempts_count).to eq 2
    end
  end
end
