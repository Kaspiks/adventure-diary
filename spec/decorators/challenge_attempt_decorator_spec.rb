# frozen_string_literal: true

require "rails_helper"

RSpec.describe ChallengeAttemptDecorator do
  describe "#status_name" do
    it "returns the attempt status name" do
      status = double("AttemptStatus", name: "Submitted")
      instance = decorated_instance_double(ChallengeAttempt, attempt_status: status)

      expect(instance.status_name).to eq "Submitted"
    end

    context "when attempt status is nil" do
      it "returns nil" do
        instance = decorated_instance_double(ChallengeAttempt, attempt_status: nil)

        expect(instance.status_name).to be_nil
      end
    end
  end

  describe "#status_color" do
    context "when status is started" do
      it "returns 'blue'" do
        status = double("AttemptStatus", code: "started")
        instance = decorated_instance_double(ChallengeAttempt, attempt_status: status)

        expect(instance.status_color).to eq "blue"
      end
    end

    context "when status is submitted" do
      it "returns 'amber'" do
        status = double("AttemptStatus", code: "submitted")
        instance = decorated_instance_double(ChallengeAttempt, attempt_status: status)

        expect(instance.status_color).to eq "amber"
      end
    end

    context "when status is approved" do
      it "returns 'emerald'" do
        status = double("AttemptStatus", code: "approved")
        instance = decorated_instance_double(ChallengeAttempt, attempt_status: status)

        expect(instance.status_color).to eq "emerald"
      end
    end

    context "when status is rejected" do
      it "returns 'red'" do
        status = double("AttemptStatus", code: "rejected")
        instance = decorated_instance_double(ChallengeAttempt, attempt_status: status)

        expect(instance.status_color).to eq "red"
      end
    end

    context "when status is unknown" do
      it "returns 'slate'" do
        status = double("AttemptStatus", code: "unknown")
        instance = decorated_instance_double(ChallengeAttempt, attempt_status: status)

        expect(instance.status_color).to eq "slate"
      end
    end

    context "when attempt status is nil" do
      it "returns 'slate'" do
        instance = decorated_instance_double(ChallengeAttempt, attempt_status: nil)

        expect(instance.status_color).to eq "slate"
      end
    end
  end

  describe "#user_name" do
    it "returns the user's full name" do
      user = double("User", full_name: "John Doe")
      instance = decorated_instance_double(ChallengeAttempt, user: user)

      expect(instance.user_name).to eq "John Doe"
    end

    context "when user is nil" do
      it "returns nil" do
        instance = decorated_instance_double(ChallengeAttempt, user: nil)

        expect(instance.user_name).to be_nil
      end
    end
  end

  describe "#challenge_title" do
    it "returns the challenge title" do
      challenge = double("Challenge", title: "Photo Challenge")
      instance = decorated_instance_double(ChallengeAttempt, challenge: challenge)

      expect(instance.challenge_title).to eq "Photo Challenge"
    end

    context "when challenge is nil" do
      it "returns nil" do
        instance = decorated_instance_double(ChallengeAttempt, challenge: nil)

        expect(instance.challenge_title).to be_nil
      end
    end
  end

  describe "#reviewer_name" do
    it "returns the reviewer's full name" do
      reviewer = double("User", full_name: "Jane Reviewer")
      instance = decorated_instance_double(ChallengeAttempt, reviewer_user: reviewer)

      expect(instance.reviewer_name).to eq "Jane Reviewer"
    end

    context "when reviewer is nil" do
      it "returns nil" do
        instance = decorated_instance_double(ChallengeAttempt, reviewer_user: nil)

        expect(instance.reviewer_name).to be_nil
      end
    end
  end

  describe "#points_display" do
    it "returns formatted points when score is awarded" do
      instance = decorated_instance_double(ChallengeAttempt, score_awarded: 50)

      expect(instance.points_display).to eq "50 pts"
    end

    context "when score_awarded is nil" do
      it "returns '-'" do
        instance = decorated_instance_double(ChallengeAttempt, score_awarded: nil)

        expect(instance.points_display).to eq "-"
      end
    end
  end

  describe "#started_at_formatted" do
    it "returns the formatted started_at date" do
      timestamp = DateTime.parse("2024-01-15 14:30:00")
      instance = decorated_instance_double(ChallengeAttempt, started_at: timestamp)

      expect(instance.started_at_formatted).to eq "January 15, 2024 14:30"
    end

    context "when started_at is nil" do
      it "returns nil" do
        instance = decorated_instance_double(ChallengeAttempt, started_at: nil)

        expect(instance.started_at_formatted).to be_nil
      end
    end
  end

  describe "#submitted_at_formatted" do
    it "returns the formatted submitted_at date" do
      timestamp = DateTime.parse("2024-01-16 10:00:00")
      instance = decorated_instance_double(ChallengeAttempt, submitted_at: timestamp)

      expect(instance.submitted_at_formatted).to eq "January 16, 2024 10:00"
    end

    context "when submitted_at is nil" do
      it "returns nil" do
        instance = decorated_instance_double(ChallengeAttempt, submitted_at: nil)

        expect(instance.submitted_at_formatted).to be_nil
      end
    end
  end

  describe "#reviewed_at_formatted" do
    it "returns the formatted reviewed_at date" do
      timestamp = DateTime.parse("2024-01-17 16:45:00")
      instance = decorated_instance_double(ChallengeAttempt, reviewed_at: timestamp)

      expect(instance.reviewed_at_formatted).to eq "January 17, 2024 16:45"
    end

    context "when reviewed_at is nil" do
      it "returns nil" do
        instance = decorated_instance_double(ChallengeAttempt, reviewed_at: nil)

        expect(instance.reviewed_at_formatted).to be_nil
      end
    end
  end
end
