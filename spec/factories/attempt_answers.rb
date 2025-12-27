# frozen_string_literal: true

FactoryBot.define do
  factory :attempt_answer do
    sequence(:field_id) { |n| "field_#{n}" }
    answer_value { "test answer" }
    answer_data { {} }
    is_correct { nil }

    association :challenge_attempt

    trait :correct do
      is_correct { true }
    end

    trait :incorrect do
      is_correct { false }
    end

    trait :with_multiple_values do
      answer_data { { "values" => %w[A C] } }
    end
  end
end




