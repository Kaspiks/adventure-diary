# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    first_name { "Test" }
    last_name { "User" }
    password { "password123" }
    password_confirmation { "password123" }
    admin { false }
    blocked { false }
    reward_points { 0 }

    trait :admin do
      admin { true }
      association :role, factory: [:role, :administrator]
    end

    trait :administrator do
      admin { false }
      association :role, factory: [:role, :administrator]
    end

    trait :company_user do
      admin { false }
      association :role, factory: [:role, :company_user]
    end

    trait :general_user do
      admin { false }
      association :role, factory: [:role, :general_user]
    end

    trait :blocked do
      blocked { true }
    end

    trait :with_points do
      reward_points { 100 }
    end
  end
end

