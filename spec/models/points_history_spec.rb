# frozen_string_literal: true

require "rails_helper"

RSpec.describe PointsHistory, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:challenge).optional }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:delta_points) }
    it { is_expected.to validate_numericality_of(:delta_points).only_integer }
    it { is_expected.to validate_presence_of(:reason_code) }
    it { is_expected.to validate_length_of(:reason_code).is_at_most(50) }
  end

  describe "constants" do
    it "defines REASON_CHALLENGE_AWARD" do
      expect(described_class::REASON_CHALLENGE_AWARD).to eq("challenge_award")
    end

    it "defines REASON_REWARD_REDEMPTION" do
      expect(described_class::REASON_REWARD_REDEMPTION).to eq("reward_redemption")
    end
  end

  describe "scopes" do
    let(:user) { create(:user, :general_user) }
    let(:challenge) { create(:challenge) }
    let!(:history1) { create(:points_history, user: user, challenge: challenge) }
    let!(:history2) { create(:points_history, user: user, challenge: nil) }

    describe ".for_user" do
      it "returns history for specific user" do
        expect(described_class.for_user(user)).to include(history1, history2)
      end
    end

    describe ".for_challenge" do
      it "returns history for specific challenge" do
        expect(described_class.for_challenge(challenge)).to include(history1)
        expect(described_class.for_challenge(challenge)).not_to include(history2)
      end
    end
  end
end

# == Schema Information
#
# Table name: points_history
#
#  id           :bigint           not null, primary key
#  delta_points :integer          not null
#  reason_code  :string(50)       not null
#  created_at   :datetime         not null
#  challenge_id :integer
#  order_id     :integer
#  user_id      :integer          not null
#
# Indexes
#
#  index_points_history_on_challenge_id  (challenge_id)
#  index_points_history_on_created_at    (created_at)
#  index_points_history_on_reason_code   (reason_code)
#  index_points_history_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (challenge_id => challenges.id)
#  fk_rails_...  (user_id => users.id)
#





