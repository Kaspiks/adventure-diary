# frozen_string_literal: true

FactoryBot.define do
  factory :reward do
    sequence(:title) { |n| "Reward #{n}" }
    description { "Test reward description" }
    cost_points { 100 }
    is_active { true }
    stock_quantity { nil }

    association :owner_user, factory: [:user, :company_user]

    trait :inactive do
      is_active { false }
    end

    trait :with_limited_stock do
      stock_quantity { 10 }
    end

    trait :out_of_stock do
      stock_quantity { 0 }
    end

    trait :expensive do
      cost_points { 1000 }
    end

    trait :cheap do
      cost_points { 10 }
    end
  end
end

# == Schema Information
#
# Table name: rewards
#
#  id             :bigint           not null, primary key
#  cost_points    :integer          not null
#  description    :text
#  is_active      :boolean          default(TRUE), not null
#  stock_quantity :integer
#  title          :string(255)      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  owner_user_id  :bigint           not null
#
# Indexes
#
#  index_rewards_on_cost_points    (cost_points)
#  index_rewards_on_is_active      (is_active)
#  index_rewards_on_owner_user_id  (owner_user_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_user_id => users.id)
#

