# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rewards::Purchase do
  let!(:pending_status) { create(:order_status, :pending) }
  let(:user) { create(:user, :general_user, reward_points: 500) }
  let(:company_user) { create(:user, :company_user) }
  let(:reward) { create(:reward, owner_user: company_user, cost_points: 100, is_active: true) }

  subject { described_class.new(user: user, reward: reward) }

  describe "#call" do
    context "with valid purchase" do
      it "returns a successful result" do
        result = subject.call
        expect(result).to be_success
      end

      it "creates an order" do
        expect { subject.call }.to change(Order, :count).by(1)
      end

      it "creates order with pending status" do
        result = subject.call
        expect(result.order.order_status.code).to eq("pending")
      end

      it "creates order with correct total_points" do
        result = subject.call
        expect(result.order.total_points).to eq(100)
      end

      it "deducts points from user" do
        expect { subject.call }.to change { user.reload.reward_points }.from(500).to(400)
      end

      it "creates points history entry" do
        expect { subject.call }.to change(PointsHistory, :count).by(1)
      end

      it "creates points history with correct values" do
        result = subject.call
        history = PointsHistory.last
        expect(history.delta_points).to eq(-100)
        expect(history.reason_code).to eq("reward_purchase")
        expect(history.order).to eq(result.order)
      end
    end

    context "with insufficient points" do
      let(:user) { create(:user, :general_user, reward_points: 50) }

      it "returns a failure result" do
        result = subject.call
        expect(result).to be_failure
      end

      it "does not create an order" do
        expect { subject.call }.not_to change(Order, :count)
      end

      it "does not deduct points" do
        expect { subject.call }.not_to(change { user.reload.reward_points })
      end

      it "includes error message" do
        result = subject.call
        expect(result.errors).to include("Insufficient points to purchase this reward")
      end
    end

    context "with inactive reward" do
      let(:reward) { create(:reward, :inactive, owner_user: company_user, cost_points: 100) }

      it "returns a failure result" do
        result = subject.call
        expect(result).to be_failure
      end

      it "does not create an order" do
        expect { subject.call }.not_to change(Order, :count)
      end

      it "includes error message" do
        result = subject.call
        expect(result.errors).to include("This reward is not available for purchase")
      end
    end

    context "with out of stock reward" do
      let(:reward) { create(:reward, :out_of_stock, owner_user: company_user, cost_points: 100) }

      it "returns a failure result" do
        result = subject.call
        expect(result).to be_failure
      end

      it "does not create an order" do
        expect { subject.call }.not_to change(Order, :count)
      end

      it "includes error message" do
        result = subject.call
        expect(result.errors).to include("This reward is out of stock")
      end
    end

    context "with limited stock" do
      let(:reward) { create(:reward, :with_limited_stock, owner_user: company_user, cost_points: 100, stock_quantity: 5) }

      it "decrements stock quantity" do
        expect { subject.call }.to change { reward.reload.stock_quantity }.from(5).to(4)
      end
    end

    context "concurrent purchase safety", concurrent: true do
      let(:reward) { create(:reward, :with_limited_stock, owner_user: company_user, cost_points: 100, stock_quantity: 1) }

      it "prevents double-spend with locking" do
        user2 = create(:user, :general_user, reward_points: 500)

        results = Queue.new
        threads = [
          Thread.new do
            ActiveRecord::Base.connection_pool.with_connection do
              results << described_class.new(user: user, reward: reward).call
            end
          end,
          Thread.new do
            ActiveRecord::Base.connection_pool.with_connection do
              results << described_class.new(user: user2, reward: reward).call
            end
          end
        ]
        threads.each { |t| t.join(5) } # 5 second timeout

        results_array = []
        results_array << results.pop until results.empty?

        successful = results_array.count(&:success?)
        failed = results_array.count(&:failure?)

        expect(successful).to eq(1)
        expect(failed).to eq(1)
        expect(reward.reload.stock_quantity).to eq(0)
      end
    end
  end
end

