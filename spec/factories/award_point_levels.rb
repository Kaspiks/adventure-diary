# frozen_string_literal: true

FactoryBot.define do
  factory :award_point_level do
    sequence(:code) { |n| "award_#{n}" }
    sequence(:name) { |n| "Award #{n}" }
    points { 10 }
    description { "Test award level" }

    trait :bronze do
      initialize_with { AwardPointLevel.find_or_create_by(code: "bronze") }
      code { "bronze" }
      name { "Bronze" }
      points { 10 }
    end

    trait :silver do
      initialize_with { AwardPointLevel.find_or_create_by(code: "silver") }
      code { "silver" }
      name { "Silver" }
      points { 25 }
    end
  end
end

# == Schema Information
#
# Table name: award_point_levels
#
#  id          :bigint           not null, primary key
#  code        :string(50)       not null
#  description :text
#  name        :string(100)      not null
#  points      :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_award_point_levels_on_code  (code) UNIQUE
#
