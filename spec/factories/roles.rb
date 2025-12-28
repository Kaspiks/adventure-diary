# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "role_#{n}" }
    description { "Test role description" }

    trait :administrator do
      initialize_with { Role.find_or_create_by(name: "administrator") }
      name { "administrator" }
      description { "Full system access" }
    end

    trait :company_user do
      initialize_with { Role.find_or_create_by(name: "company_user") }
      name { "company_user" }
      description { "Can create challenges and review own attempts" }
    end

    trait :general_user do
      initialize_with { Role.find_or_create_by(name: "general_user") }
      name { "general_user" }
      description { "Regular users who complete challenges" }
    end
  end
end

# == Schema Information
#
# Table name: roles
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string(100)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_roles_on_name  (name) UNIQUE
#
