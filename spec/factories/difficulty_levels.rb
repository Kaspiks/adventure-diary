# frozen_string_literal: true

FactoryBot.define do
  factory :difficulty_level do
    sequence(:code) { |n| "difficulty_#{n}" }
    sequence(:name) { |n| "Difficulty #{n}" }
    description { "Test difficulty level" }
    sort_order { 0 }

    trait :easy do
      code { "easy" }
      name { "Easy" }
      sort_order { 1 }
    end

    trait :medium do
      code { "medium" }
      name { "Medium" }
      sort_order { 2 }
    end
  end
end
