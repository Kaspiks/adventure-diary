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

    trait :with_location do
      association :location
    end

    trait :quiz do
      association :challenge_type, factory: [:challenge_type, :quiz]
    end

    trait :photo do
      association :challenge_type, factory: [:challenge_type, :photo]
    end

    trait :exploration do
      association :challenge_type, factory: [:challenge_type, :exploration]
    end

    trait :with_text_field do
      fields_config do
        [
          {
            "id" => SecureRandom.uuid,
            "type" => "text_input",
            "label" => "What is the answer?",
            "instructions" => "Enter the correct answer",
            "required" => true,
            "points" => 10,
            "correct_answer" => "correct"
          }
        ]
      end
    end

    trait :with_single_choice do
      fields_config do
        [
          {
            "id" => SecureRandom.uuid,
            "type" => "single_choice",
            "label" => "Pick the right option",
            "instructions" => "Select one",
            "required" => true,
            "points" => 10,
            "options" => %w[A B C D],
            "correct_answer" => "B"
          }
        ]
      end
    end

    trait :with_multiple_choice do
      fields_config do
        [
          {
            "id" => SecureRandom.uuid,
            "type" => "multiple_choice",
            "label" => "Select all correct",
            "instructions" => "Select all that apply",
            "required" => true,
            "points" => 15,
            "options" => %w[A B C D],
            "correct_answers" => %w[A C]
          }
        ]
      end
    end

    trait :with_photo_upload do
      association :challenge_type, factory: [:challenge_type, :photo]
      fields_config do
        [
          {
            "id" => SecureRandom.uuid,
            "type" => "photo_upload",
            "label" => "Upload photo",
            "instructions" => "Take a photo",
            "required" => true,
            "max_photos" => 3
          }
        ]
      end
    end

    trait :with_hidden_letter do
      association :challenge_type, factory: [:challenge_type, :exploration]
      fields_config do
        [
          {
            "id" => SecureRandom.uuid,
            "type" => "hidden_letter",
            "label" => "Find the hidden letters",
            "instructions" => "Look for clues",
            "required" => true,
            "points" => 20,
            "display_text" => "The ___ is hidden",
            "number_of_blanks" => 3,
            "correct_answer" => "KEY",
            "case_sensitive" => false,
            "hint" => "It opens doors"
          }
        ]
      end
    end

    trait :with_mixed_fields do
      fields_config do
        [
          {
            "id" => SecureRandom.uuid,
            "type" => "text_input",
            "label" => "Question 1",
            "required" => true,
            "points" => 10,
            "correct_answer" => "answer1"
          },
          {
            "id" => SecureRandom.uuid,
            "type" => "single_choice",
            "label" => "Question 2",
            "required" => true,
            "points" => 10,
            "options" => %w[A B C],
            "correct_answer" => "B"
          }
        ]
      end
    end
  end
end

