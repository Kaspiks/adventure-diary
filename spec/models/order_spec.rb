# frozen_string_literal: true

require "rails_helper"

RSpec.describe Order, type: :model do
  let!(:pending_status) { create(:order_status, :pending) }
  let!(:approved_status) { create(:order_status, :approved) }
  let!(:delivered_status) { create(:order_status, :delivered) }
  let!(:cancelled_status) { create(:order_status, :cancelled) }

  describe "validations" do
    subject { build(:order) }

    it { should validate_presence_of(:total_points) }
    it { should validate_numericality_of(:total_points).only_integer.is_greater_than(0) }
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:reward) }
    it { should belong_to(:order_status) }
  end

  describe "#can_transition_to?" do
    let(:order) { create(:order, order_status: pending_status) }

    context "from pending" do
      it "can transition to approved" do
        expect(order.can_transition_to?("approved")).to be true
      end

      it "can transition to cancelled" do
        expect(order.can_transition_to?("cancelled")).to be true
      end

      it "cannot transition to delivered" do
        expect(order.can_transition_to?("delivered")).to be false
      end
    end

    context "from approved" do
      before { order.update!(order_status: approved_status) }

      it "can transition to delivered" do
        expect(order.can_transition_to?("delivered")).to be true
      end

      it "can transition to cancelled" do
        expect(order.can_transition_to?("cancelled")).to be true
      end

      it "cannot transition to pending" do
        expect(order.can_transition_to?("pending")).to be false
      end
    end

    context "from final status (delivered)" do
      before { order.update!(order_status: delivered_status) }

      it "cannot transition to any status" do
        expect(order.can_transition_to?("cancelled")).to be false
        expect(order.can_transition_to?("approved")).to be false
      end
    end
  end

  describe "#transition_to!" do
    let(:order) { create(:order, order_status: pending_status) }

    it "transitions to valid status" do
      order.transition_to!("approved")
      expect(order.reload.order_status.code).to eq("approved")
    end

    it "raises error for invalid transition" do
      expect { order.transition_to!("delivered") }.to raise_error("Invalid transition from pending to delivered")
    end
  end
end

# == Schema Information
#
# Table name: orders
#
#  id              :bigint           not null, primary key
#  total_points    :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  order_status_id :bigint           not null
#  reward_id       :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_orders_on_order_status_id                (order_status_id)
#  index_orders_on_reward_id                      (reward_id)
#  index_orders_on_reward_id_and_order_status_id  (reward_id,order_status_id)
#  index_orders_on_user_id                        (user_id)
#  index_orders_on_user_id_and_created_at         (user_id,created_at)
#
# Foreign Keys
#
#  fk_rails_...  (order_status_id => order_statuses.id)
#  fk_rails_...  (reward_id => rewards.id)
#  fk_rails_...  (user_id => users.id)
#

