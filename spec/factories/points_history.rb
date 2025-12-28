# frozen_string_literal: true

FactoryBot.define do
  factory :points_history do
    delta_points { 10 }
    reason_code { PointsHistory::REASON_CHALLENGE_AWARD }

    association :user
    challenge { nil }

    trait :challenge_award do
      reason_code { PointsHistory::REASON_CHALLENGE_AWARD }
      association :challenge
    end

    trait :reward_redemption do
      reason_code { PointsHistory::REASON_REWARD_REDEMPTION }
      delta_points { -25 }
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




