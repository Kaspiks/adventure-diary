# frozen_string_literal: true

FactoryBot.define do
  factory :challenge_attempt do
    started_at { Time.current }
    submitted_at { nil }
    reviewed_at { nil }
    score_awarded { nil }
    evidence_url { nil }

    association :user, factory: [:user, :general_user]
    association :challenge
    association :attempt_status, factory: [:attempt_status, :started]

    trait :started do
      association :attempt_status, factory: [:attempt_status, :started]
    end

    trait :submitted do
      association :attempt_status, factory: [:attempt_status, :submitted]
      submitted_at { Time.current }
    end

    trait :approved do
      association :attempt_status, factory: [:attempt_status, :approved]
      submitted_at { Time.current }
      reviewed_at { Time.current }
      score_awarded { 10 }
      association :reviewer_user, factory: :user
    end

    trait :rejected do
      association :attempt_status, factory: [:attempt_status, :rejected]
      submitted_at { Time.current }
      reviewed_at { Time.current }
      score_awarded { 0 }
      association :reviewer_user, factory: :user
    end
  end
end

# == Schema Information
#
# Table name: challenge_attempts
#
#  id                :bigint           not null, primary key
#  evidence_url      :string(500)
#  reviewed_at       :datetime
#  score_awarded     :integer
#  started_at        :datetime         not null
#  submitted_at      :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  attempt_status_id :integer          not null
#  challenge_id      :integer          not null
#  reviewer_user_id  :integer
#  user_id           :integer          not null
#
# Indexes
#
#  index_challenge_attempts_on_attempt_status_id         (attempt_status_id)
#  index_challenge_attempts_on_challenge_id              (challenge_id)
#  index_challenge_attempts_on_reviewer_user_id          (reviewer_user_id)
#  index_challenge_attempts_on_user_id                   (user_id)
#  index_challenge_attempts_on_user_id_and_challenge_id  (user_id,challenge_id)
#
# Foreign Keys
#
#  fk_rails_...  (attempt_status_id => attempt_statuses.id)
#  fk_rails_...  (challenge_id => challenges.id)
#  fk_rails_...  (reviewer_user_id => users.id)
#  fk_rails_...  (user_id => users.id)
#
