# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reward, type: :model do
  let(:company_user) { create(:user, :company_user) }

  describe "validations" do
    subject { build(:reward, owner_user: company_user) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:cost_points) }
    it { should validate_numericality_of(:cost_points).only_integer.is_greater_than(0) }
    it { should validate_numericality_of(:stock_quantity).only_integer.is_greater_than_or_equal_to(0).allow_nil }
  end

  describe "associations" do
    it { should belong_to(:owner_user).class_name("User") }
    it { should have_many(:orders) }
  end

  describe "scopes" do
    let!(:active_reward) { create(:reward, is_active: true, owner_user: company_user) }
    let!(:inactive_reward) { create(:reward, is_active: false, owner_user: company_user) }
    let!(:in_stock_reward) { create(:reward, stock_quantity: 5, owner_user: company_user) }
    let!(:out_of_stock_reward) { create(:reward, stock_quantity: 0, owner_user: company_user) }

    describe ".active" do
      it "returns only active rewards" do
        expect(described_class.active).to include(active_reward)
        expect(described_class.active).not_to include(inactive_reward)
      end
    end

    describe ".in_stock" do
      it "returns rewards in stock or with unlimited stock" do
        expect(described_class.in_stock).to include(in_stock_reward, active_reward)
        expect(described_class.in_stock).not_to include(out_of_stock_reward)
      end
    end

    describe ".available" do
      it "returns active and in-stock rewards" do
        expect(described_class.available).to include(active_reward, in_stock_reward)
        expect(described_class.available).not_to include(inactive_reward, out_of_stock_reward)
      end
    end
  end

  describe "#owned_by?" do
    let(:reward) { create(:reward, owner_user: company_user) }
    let(:other_user) { create(:user, :company_user) }

    it "returns true for owner" do
      expect(reward.owned_by?(company_user)).to be true
    end

    it "returns false for non-owner" do
      expect(reward.owned_by?(other_user)).to be false
    end

    it "returns false for nil user" do
      expect(reward.owned_by?(nil)).to be false
    end
  end

  describe "#in_stock?" do
    it "returns true when stock_quantity is nil" do
      reward = build(:reward, stock_quantity: nil)
      expect(reward.in_stock?).to be true
    end

    it "returns true when stock_quantity is positive" do
      reward = build(:reward, stock_quantity: 5)
      expect(reward.in_stock?).to be true
    end

    it "returns false when stock_quantity is zero" do
      reward = build(:reward, stock_quantity: 0)
      expect(reward.in_stock?).to be false
    end
  end

  describe "#decrement_stock!" do
    let(:reward) { create(:reward, stock_quantity: 5, owner_user: company_user) }

    it "decrements stock_quantity by 1" do
      expect { reward.decrement_stock! }.to change { reward.reload.stock_quantity }.from(5).to(4)
    end

    it "raises error when out of stock" do
      reward.update!(stock_quantity: 0)
      expect { reward.decrement_stock! }.to raise_error("Out of stock")
    end

    it "does nothing when stock_quantity is nil" do
      reward.update!(stock_quantity: nil)
      expect { reward.decrement_stock! }.not_to raise_error
    end
  end
end

# == Schema Information
#
# Table name: rewards
#
#  id             :bigint           not null, primary key
#  cost_points    :integer          not null
#  description    :text
#  is_active      :boolean          default(TRUE), not null
#  stock_quantity :integer
#  title          :string(255)      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  owner_user_id  :bigint           not null
#
# Indexes
#
#  index_rewards_on_cost_points    (cost_points)
#  index_rewards_on_is_active      (is_active)
#  index_rewards_on_owner_user_id  (owner_user_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_user_id => users.id)
#

