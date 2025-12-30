# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    total_points { 100 }

    association :user, factory: [:user, :general_user]
    association :reward
    association :order_status, factory: [:order_status, :pending]

    trait :pending do
      association :order_status, factory: [:order_status, :pending]
    end

    trait :approved do
      association :order_status, factory: [:order_status, :approved]
    end

    trait :delivered do
      association :order_status, factory: [:order_status, :delivered]
    end

    trait :cancelled do
      association :order_status, factory: [:order_status, :cancelled]
    end
  end
end

# == Schema Information
#
# Table name: orders
#
#  id              :bigint           not null, primary key
#  total_points    :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  order_status_id :bigint           not null
#  reward_id       :bigint           not null
#  user_id         :bigint           not null
#
# Indexes
#
#  index_orders_on_order_status_id                (order_status_id)
#  index_orders_on_reward_id                      (reward_id)
#  index_orders_on_reward_id_and_order_status_id  (reward_id,order_status_id)
#  index_orders_on_user_id                        (user_id)
#  index_orders_on_user_id_and_created_at         (user_id,created_at)
#
# Foreign Keys
#
#  fk_rails_...  (order_status_id => order_statuses.id)
#  fk_rails_...  (reward_id => rewards.id)
#  fk_rails_...  (user_id => users.id)
#

