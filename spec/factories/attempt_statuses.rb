# frozen_string_literal: true

FactoryBot.define do
  factory :attempt_status do
    sequence(:code) { |n| "status_#{n}" }
    sequence(:name) { |n| "Status #{n}" }
    is_final { false }

    trait :started do
      code { "started" }
      name { "Started" }
      is_final { false }
    end

    trait :submitted do
      code { "submitted" }
      name { "Submitted" }
      is_final { false }
    end

    trait :approved do
      code { "approved" }
      name { "Approved" }
      is_final { true }
    end

    trait :rejected do
      code { "rejected" }
      name { "Rejected" }
      is_final { true }
    end
  end
end

