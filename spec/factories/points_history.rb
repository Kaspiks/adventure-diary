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

