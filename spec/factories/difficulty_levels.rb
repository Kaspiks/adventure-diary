# frozen_string_literal: true

FactoryBot.define do
  factory :difficulty_level do
    sequence(:code) { |n| "difficulty_#{n}" }
    sequence(:name) { |n| "Difficulty #{n}" }
    description { "Test difficulty level" }
    sort_order { 0 }

    trait :easy do
      initialize_with { DifficultyLevel.find_or_create_by(code: "easy") }
      code { "easy" }
      name { "Easy" }
      sort_order { 1 }
    end

    trait :medium do
      initialize_with { DifficultyLevel.find_or_create_by(code: "medium") }
      code { "medium" }
      name { "Medium" }
      sort_order { 2 }
    end
  end
end

# == Schema Information
#
# Table name: difficulty_levels
#
#  id          :bigint           not null, primary key
#  code        :string(50)       not null
#  description :text
#  name        :string(100)      not null
#  sort_order  :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_difficulty_levels_on_code        (code) UNIQUE
#  index_difficulty_levels_on_sort_order  (sort_order)
#
