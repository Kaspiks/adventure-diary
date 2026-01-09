# frozen_string_literal: true

require "rails_helper"

RSpec.describe RewardDecorator do
  describe "#status_badge" do
    context "when reward is active" do
      it "returns 'Active'" do
        instance = decorated_instance_double(Reward, is_active: true)

        expect(instance.status_badge).to eq "Active"
      end
    end

    context "when reward is inactive" do
      it "returns 'Inactive'" do
        instance = decorated_instance_double(Reward, is_active: false)

        expect(instance.status_badge).to eq "Inactive"
      end
    end
  end

  describe "#status_color" do
    context "when reward is active" do
      it "returns 'emerald'" do
        instance = decorated_instance_double(Reward, is_active: true)

        expect(instance.status_color).to eq "emerald"
      end
    end

    context "when reward is inactive" do
      it "returns 'slate'" do
        instance = decorated_instance_double(Reward, is_active: false)

        expect(instance.status_color).to eq "slate"
      end
    end
  end

  describe "#stock_display" do
    context "when reward has no stock limit" do
      it "returns 'Unlimited'" do
        object = instance_double(Reward, has_stock_limit?: false)
        instance = RewardDecorator.new(object)

        expect(instance.stock_display).to eq "Unlimited"
      end
    end

    context "when reward is out of stock" do
      it "returns 'Out of Stock'" do
        object = instance_double(Reward, has_stock_limit?: true, out_of_stock?: true)
        instance = RewardDecorator.new(object)

        expect(instance.stock_display).to eq "Out of Stock"
      end
    end

    context "when reward has stock available" do
      it "returns the stock quantity with 'left'" do
        object = instance_double(Reward, has_stock_limit?: true, out_of_stock?: false, stock_quantity: 15)
        instance = RewardDecorator.new(object)

        expect(instance.stock_display).to eq "15 left"
      end
    end
  end

  describe "#stock_color" do
    context "when reward has no stock limit" do
      it "returns 'slate'" do
        object = instance_double(Reward, has_stock_limit?: false)
        instance = RewardDecorator.new(object)

        expect(instance.stock_color).to eq "slate"
      end
    end

    context "when reward is out of stock" do
      it "returns 'red'" do
        object = instance_double(Reward, has_stock_limit?: true, out_of_stock?: true)
        instance = RewardDecorator.new(object)

        expect(instance.stock_color).to eq "red"
      end
    end

    context "when stock is low (less than 5)" do
      it "returns 'amber'" do
        object = instance_double(Reward, has_stock_limit?: true, out_of_stock?: false, stock_quantity: 3)
        instance = RewardDecorator.new(object)

        expect(instance.stock_color).to eq "amber"
      end
    end

    context "when stock is sufficient" do
      it "returns 'emerald'" do
        object = instance_double(Reward, has_stock_limit?: true, out_of_stock?: false, stock_quantity: 10)
        instance = RewardDecorator.new(object)

        expect(instance.stock_color).to eq "emerald"
      end
    end
  end

  describe "#cost_display" do
    it "returns formatted points string" do
      instance = decorated_instance_double(Reward, cost_points: 500)

      expect(instance.cost_display).to eq "500 pts"
    end
  end

  describe "#owner_name" do
    it "returns the owner's full name" do
      owner = double("User", full_name: "Shop Owner")
      instance = decorated_instance_double(Reward, owner_user: owner)

      expect(instance.owner_name).to eq "Shop Owner"
    end

    context "when owner is nil" do
      it "returns nil" do
        instance = decorated_instance_double(Reward, owner_user: nil)

        expect(instance.owner_name).to be_nil
      end
    end
  end

  describe "#orders_count" do
    it "returns the count of orders" do
      orders = double("orders", count: 10)
      instance = decorated_instance_double(Reward, orders: orders)

      expect(instance.orders_count).to eq 10
    end
  end

  describe "#pending_orders_count" do
    it "returns the count of pending orders" do
      pending_scope = double("pending_scope", count: 3)
      orders = double("orders", pending: pending_scope)
      instance = decorated_instance_double(Reward, orders: orders)

      expect(instance.pending_orders_count).to eq 3
    end
  end

  describe "#truncated_description" do
    it "truncates long description" do
      long_desc = "A" * 200
      instance = decorated_instance_double(Reward, description: long_desc)

      result = instance.truncated_description(length: 100)
      expect(result.length).to eq 100
      expect(result).to end_with("...")
    end

    it "strips HTML tags from description" do
      html_desc = "<p>This is a <strong>great</strong> reward!</p>"
      instance = decorated_instance_double(Reward, description: html_desc)

      result = instance.truncated_description(length: 100)
      expect(result).not_to include("<p>")
      expect(result).not_to include("<strong>")
      expect(result).to include("This is a great reward!")
    end

    context "when description is nil" do
      it "returns empty string" do
        instance = decorated_instance_double(Reward, description: nil)

        expect(instance.truncated_description).to eq ""
      end
    end

    context "when description is blank" do
      it "returns empty string" do
        instance = decorated_instance_double(Reward, description: "")

        expect(instance.truncated_description).to eq ""
      end
    end
  end

  describe "#has_image?" do
    context "when image is attached" do
      it "returns true" do
        image = double("image", attached?: true)
        object = instance_double(Reward, image: image)
        instance = RewardDecorator.new(object)

        expect(instance.has_image?).to be true
      end
    end

    context "when image is not attached" do
      it "returns false" do
        image = double("image", attached?: false)
        object = instance_double(Reward, image: image)
        instance = RewardDecorator.new(object)

        expect(instance.has_image?).to be false
      end
    end
  end
end
