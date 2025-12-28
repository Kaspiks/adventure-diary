# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    first_name { "Test" }
    last_name { "User" }
    password { "password123" }
    password_confirmation { "password123" }
    admin { false }
    blocked { false }
    reward_points { 0 }

    trait :admin do
      admin { true }
      association :role, factory: [:role, :administrator]
    end

    trait :administrator do
      admin { false }
      association :role, factory: [:role, :administrator]
    end

    trait :company_user do
      admin { false }
      association :role, factory: [:role, :company_user]
    end

    trait :general_user do
      admin { false }
      association :role, factory: [:role, :general_user]
    end

    trait :blocked do
      blocked { true }
    end

    trait :with_points do
      reward_points { 100 }
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  admin                  :boolean          default(FALSE), not null
#  blocked                :boolean          default(FALSE), not null
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(45)
#  email                  :string(255)      not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  first_name             :string(255)      not null
#  last_name              :string(255)      not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(45)
#  locked_at              :datetime
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  reward_points          :integer          default(0), not null
#  session_token          :string(20)
#  sign_in_count          :integer          default(0), not null
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  role_id                :integer
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_role_id               (role_id)
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (role_id => roles.id)
#
