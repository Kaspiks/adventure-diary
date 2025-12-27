# frozen_string_literal: true

FactoryBot.define do
  factory :award_point_level do
    sequence(:code) { |n| "award_#{n}" }
    sequence(:name) { |n| "Award #{n}" }
    points { 10 }
    description { "Test award level" }

    trait :bronze do
      code { "bronze" }
      name { "Bronze" }
      points { 10 }
    end

    trait :silver do
      code { "silver" }
      name { "Silver" }
      points { 25 }
    end
  end
end
