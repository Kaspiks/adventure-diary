# frozen_string_literal: true

FactoryBot.define do
  factory :permission do
    sequence(:code) { |n| "permission.#{n}" }
    description { "Test permission" }

    trait :challenges_create do
      code { "challenges.create" }
      description { "Can create challenges" }
    end

    trait :challenges_review do
      code { "challenges.review" }
      description { "Can review challenges" }
    end

    trait :attempts_approve do
      code { "attempts.approve" }
      description { "Can approve attempts" }
    end
  end
end





