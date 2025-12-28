# frozen_string_literal: true

FactoryBot.define do
  factory :attempt_status do
    sequence(:code) { |n| "status_#{n}" }
    sequence(:name) { |n| "Status #{n}" }
    is_final { false }

    trait :started do
      initialize_with { AttemptStatus.find_or_create_by(code: "started") }
      code { "started" }
      name { "Started" }
      is_final { false }
    end

    trait :submitted do
      initialize_with { AttemptStatus.find_or_create_by(code: "submitted") }
      code { "submitted" }
      name { "Submitted" }
      is_final { false }
    end

    trait :approved do
      initialize_with { AttemptStatus.find_or_create_by(code: "approved") }
      code { "approved" }
      name { "Approved" }
      is_final { true }
    end

    trait :rejected do
      initialize_with { AttemptStatus.find_or_create_by(code: "rejected") }
      code { "rejected" }
      name { "Rejected" }
      is_final { true }
    end
  end
end

# == Schema Information
#
# Table name: attempt_statuses
#
#  id         :bigint           not null, primary key
#  code       :string(50)       not null
#  is_final   :boolean          default(FALSE), not null
#  name       :string(100)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_attempt_statuses_on_code  (code) UNIQUE
#
