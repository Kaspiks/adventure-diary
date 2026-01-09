# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrderDecorator do
  describe "#status_name" do
    it "returns the order status name" do
      status = double("OrderStatus", name: "Pending")
      instance = decorated_instance_double(Order, order_status: status)

      expect(instance.status_name).to eq "Pending"
    end

    context "when order status is nil" do
      it "returns nil" do
        instance = decorated_instance_double(Order, order_status: nil)

        expect(instance.status_name).to be_nil
      end
    end
  end

  describe "#status_code" do
    it "returns the order status code" do
      status = double("OrderStatus", code: "pending")
      instance = decorated_instance_double(Order, order_status: status)

      expect(instance.status_code).to eq "pending"
    end
  end

  describe "#status_color" do
    context "when status is pending" do
      it "returns 'amber'" do
        status = double("OrderStatus", code: "pending")
        instance = decorated_instance_double(Order, order_status: status)

        expect(instance.status_color).to eq "amber"
      end
    end

    context "when status is approved" do
      it "returns 'blue'" do
        status = double("OrderStatus", code: "approved")
        instance = decorated_instance_double(Order, order_status: status)

        expect(instance.status_color).to eq "blue"
      end
    end

    context "when status is delivered" do
      it "returns 'emerald'" do
        status = double("OrderStatus", code: "delivered")
        instance = decorated_instance_double(Order, order_status: status)

        expect(instance.status_color).to eq "emerald"
      end
    end

    context "when status is cancelled" do
      it "returns 'red'" do
        status = double("OrderStatus", code: "cancelled")
        instance = decorated_instance_double(Order, order_status: status)

        expect(instance.status_color).to eq "red"
      end
    end

    context "when status is unknown" do
      it "returns 'slate'" do
        status = double("OrderStatus", code: "unknown")
        instance = decorated_instance_double(Order, order_status: status)

        expect(instance.status_color).to eq "slate"
      end
    end
  end

  describe "#points_display" do
    it "returns formatted points string" do
      instance = decorated_instance_double(Order, total_points: 150)

      expect(instance.points_display).to eq "150 pts"
    end
  end

  describe "#buyer_name" do
    it "returns the buyer's full name" do
      user = double("User", full_name: "John Buyer")
      instance = decorated_instance_double(Order, user: user)

      expect(instance.buyer_name).to eq "John Buyer"
    end

    context "when user is nil" do
      it "returns nil" do
        instance = decorated_instance_double(Order, user: nil)

        expect(instance.buyer_name).to be_nil
      end
    end
  end

  describe "#buyer_email" do
    it "returns the buyer's email" do
      user = double("User", email: "buyer@example.com")
      instance = decorated_instance_double(Order, user: user)

      expect(instance.buyer_email).to eq "buyer@example.com"
    end
  end

  describe "#reward_title" do
    it "returns the reward title" do
      reward = double("Reward", title: "Coffee Mug")
      instance = decorated_instance_double(Order, reward: reward)

      expect(instance.reward_title).to eq "Coffee Mug"
    end

    context "when reward is nil" do
      it "returns nil" do
        instance = decorated_instance_double(Order, reward: nil)

        expect(instance.reward_title).to be_nil
      end
    end
  end

  describe "#reward_owner_name" do
    it "returns the reward owner's full name" do
      owner = double("User", full_name: "Shop Owner")
      reward = double("Reward", owner_user: owner)
      instance = decorated_instance_double(Order, reward: reward)

      expect(instance.reward_owner_name).to eq "Shop Owner"
    end
  end

  describe "#ordered_at" do
    it "returns the formatted created_at date" do
      timestamp = Time.zone.parse("2024-01-15 14:30:00")
      instance = decorated_instance_double(Order, created_at: timestamp)

      expect(instance.ordered_at).to eq "Jan 15, 2024 14:30"
    end
  end

  describe "#can_approve?" do
    it "delegates to object.can_transition_to?" do
      object = instance_double(Order)
      allow(object).to receive(:can_transition_to?).with("approved").and_return(true)
      instance = OrderDecorator.new(object)

      expect(instance.can_approve?).to be true
    end
  end

  describe "#can_deliver?" do
    it "delegates to object.can_transition_to?" do
      object = instance_double(Order)
      allow(object).to receive(:can_transition_to?).with("delivered").and_return(true)
      instance = OrderDecorator.new(object)

      expect(instance.can_deliver?).to be true
    end
  end

  describe "#can_cancel?" do
    it "delegates to object.can_transition_to?" do
      object = instance_double(Order)
      allow(object).to receive(:can_transition_to?).with("cancelled").and_return(false)
      instance = OrderDecorator.new(object)

      expect(instance.can_cancel?).to be false
    end
  end
end
