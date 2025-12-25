# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "role_#{n}" }
    description { "Test role description" }

    trait :administrator do
      name { "administrator" }
      description { "Full system access" }
    end

    trait :company_user do
      name { "company_user" }
      description { "Can create challenges and review own attempts" }
    end

    trait :general_user do
      name { "general_user" }
      description { "Regular users who complete challenges" }
    end
  end
end

