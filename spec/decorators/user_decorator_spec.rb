# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserDecorator do
  describe "#full_name" do
    it "returns the user's full name from the delegated method" do
      instance = decorated_instance_double(User, full_name: "John Doe")

      expect(instance.full_name).to eq "John Doe"
    end
  end

  describe "#initials" do
    it "returns the user's initials from the delegated method" do
      instance = decorated_instance_double(User, initials: "JD")

      expect(instance.initials).to eq "JD"
    end
  end

  describe "#email" do
    it "returns the user's email" do
      instance = decorated_instance_double(User, email: "john@example.com")

      expect(instance.email).to eq "john@example.com"
    end
  end

  describe "#admin?" do
    context "when user is admin" do
      it "returns true" do
        instance = decorated_instance_double(User, admin?: true)

        expect(instance.admin?).to be true
      end
    end

    context "when user is not admin" do
      it "returns false" do
        instance = decorated_instance_double(User, admin?: false)

        expect(instance.admin?).to be false
      end
    end
  end

  describe "#blocked?" do
    context "when user is blocked" do
      it "returns true" do
        instance = decorated_instance_double(User, blocked?: true)

        expect(instance.blocked?).to be true
      end
    end

    context "when user is not blocked" do
      it "returns false" do
        instance = decorated_instance_double(User, blocked?: false)

        expect(instance.blocked?).to be false
      end
    end
  end

  describe "#active?" do
    context "when user is active" do
      it "returns true" do
        instance = decorated_instance_double(User, active?: true)

        expect(instance.active?).to be true
      end
    end

    context "when user is blocked" do
      it "returns false" do
        instance = decorated_instance_double(User, active?: false)

        expect(instance.active?).to be false
      end
    end
  end

  describe "#last_sign_in_at" do
    it "returns the last sign in timestamp" do
      timestamp = DateTime.parse("2024-01-15 12:00:00")
      instance = decorated_instance_double(User, last_sign_in_at: timestamp)

      expect(instance.last_sign_in_at).to eq timestamp
    end

    context "when never signed in" do
      it "returns nil" do
        instance = decorated_instance_double(User, last_sign_in_at: nil)

        expect(instance.last_sign_in_at).to be_nil
      end
    end
  end

  describe "#sign_in_count" do
    it "returns the sign in count" do
      instance = decorated_instance_double(User, sign_in_count: 5)

      expect(instance.sign_in_count).to eq 5
    end
  end
end
