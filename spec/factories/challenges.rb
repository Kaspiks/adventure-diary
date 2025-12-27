# frozen_string_literal: true

FactoryBot.define do
  factory :challenge do
    sequence(:title) { |n| "Challenge #{n}" }
    description { "Test challenge description" }
    is_active { true }
    fields_config { [] }

    association :creator_user, factory: [:user, :company_user]
    association :challenge_type, factory: [:challenge_type, :quiz]
    association :difficulty_level, factory: [:difficulty_level, :easy]
    association :award_point_level, factory: [:award_point_level, :bronze]
    location { nil }

    trait :inactive do
      is_active { false }
    end

    trait :with_text_field do
      fields_config do
        [
          {
            "id" => SecureRandom.uuid,
            "type" => "text_input",
            "label" => "What is the answer?",
            "required" => true,
            "points" => 10,
            "correct_answer" => "correct"
          }
        ]
      end
    end
  end
end
