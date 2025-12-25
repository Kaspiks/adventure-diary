# frozen_string_literal: true

FactoryBot.define do
  factory :challenge_type do
    sequence(:code) { |n| "type_#{n}" }
    sequence(:name) { |n| "Type #{n}" }
    description { "Test challenge type" }

    trait :quiz do
      code { "quiz" }
      name { "Quiz Challenge" }
      description { "Answer questions about a location or topic" }
    end

    trait :photo do
      code { "photo" }
      name { "Photo Challenge" }
      description { "Take a photo at a specific location or of a specific subject" }
    end

    trait :exploration do
      code { "exploration" }
      name { "Exploration Challenge" }
      description { "Explore and discover new places" }
    end

    trait :checkin do
      code { "checkin" }
      name { "Check-in Challenge" }
      description { "Visit and check in at a specific location" }
    end

    trait :social do
      code { "social" }
      name { "Social Challenge" }
      description { "Complete activities with other travelers" }
    end
  end
end

