# frozen_string_literal: true

FactoryBot.define do
  factory :challenge_type do
    sequence(:code) { |n| "type_#{n}" }
    sequence(:name) { |n| "Type #{n}" }
    description { "Test challenge type" }

    trait :quiz do
      code { "quiz" }
      name { "Quiz Challenge" }
    end

    trait :photo do
      code { "photo" }
      name { "Photo Challenge" }
    end

    trait :exploration do
      code { "exploration" }
      name { "Exploration Challenge" }
    end
  end
end
