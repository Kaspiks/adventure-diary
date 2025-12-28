# frozen_string_literal: true

FactoryBot.define do
  factory :challenge_type do
    sequence(:code) { |n| "type_#{n}" }
    sequence(:name) { |n| "Type #{n}" }
    description { "Test challenge type" }

    trait :quiz do
      initialize_with { ChallengeType.find_or_create_by(code: "quiz") }
      code { "quiz" }
      name { "Quiz Challenge" }
    end

    trait :photo do
      initialize_with { ChallengeType.find_or_create_by(code: "photo") }
      code { "photo" }
      name { "Photo Challenge" }
    end

    trait :exploration do
      initialize_with { ChallengeType.find_or_create_by(code: "exploration") }
      code { "exploration" }
      name { "Exploration Challenge" }
    end
  end
end

# == Schema Information
#
# Table name: challenge_types
#
#  id          :bigint           not null, primary key
#  code        :string(50)       not null
#  description :text
#  name        :string(100)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_challenge_types_on_code  (code) UNIQUE
#
