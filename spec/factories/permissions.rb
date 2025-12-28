# frozen_string_literal: true

FactoryBot.define do
  factory :permission do
    sequence(:code) { |n| "permission.#{n}" }
    description { "Test permission" }

    trait :challenges_create do
      code { "challenges.create" }
      description { "Can create challenges" }
    end

    trait :challenges_review do
      code { "challenges.review" }
      description { "Can review challenges" }
    end

    trait :attempts_approve do
      code { "attempts.approve" }
      description { "Can approve attempts" }
    end
  end
end

# == Schema Information
#
# Table name: permissions
#
#  id          :bigint           not null, primary key
#  code        :string(100)      not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_permissions_on_code  (code) UNIQUE
#





