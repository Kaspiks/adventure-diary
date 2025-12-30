# frozen_string_literal: true

FactoryBot.define do
  factory :order_status do
    sequence(:code) { |n| "status_#{n}" }
    sequence(:name) { |n| "Status #{n}" }
    is_final { false }

    trait :pending do
      code { "pending" }
      name { "Pending" }
      is_final { false }
    end

    trait :approved do
      code { "approved" }
      name { "Approved" }
      is_final { false }
    end

    trait :delivered do
      code { "delivered" }
      name { "Delivered" }
      is_final { true }
    end

    trait :cancelled do
      code { "cancelled" }
      name { "Cancelled" }
      is_final { true }
    end
  end
end

# == Schema Information
#
# Table name: order_statuses
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
#  index_order_statuses_on_code  (code) UNIQUE
#

