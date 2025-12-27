# frozen_string_literal: true

FactoryBot.define do
  factory :challenge_attempt do
    started_at { Time.current }
    submitted_at { nil }
    reviewed_at { nil }
    score_awarded { nil }
    evidence_url { nil }

    association :user, factory: [:user, :general_user]
    association :challenge
    association :attempt_status, factory: [:attempt_status, :started]

    trait :started do
      association :attempt_status, factory: [:attempt_status, :started]
    end

    trait :submitted do
      association :attempt_status, factory: [:attempt_status, :submitted]
      submitted_at { Time.current }
    end

    trait :approved do
      association :attempt_status, factory: [:attempt_status, :approved]
      submitted_at { Time.current }
      reviewed_at { Time.current }
      score_awarded { 10 }
      association :reviewer_user, factory: :user
    end

    trait :rejected do
      association :attempt_status, factory: [:attempt_status, :rejected]
      submitted_at { Time.current }
      reviewed_at { Time.current }
      score_awarded { 0 }
      association :reviewer_user, factory: :user
    end
  end
end
