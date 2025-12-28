# frozen_string_literal: true

FactoryBot.define do
  factory :attempt_answer do
    sequence(:field_id) { |n| "field_#{n}" }
    answer_value { "test answer" }
    answer_data { {} }
    is_correct { nil }

    association :challenge_attempt

    trait :correct do
      is_correct { true }
    end

    trait :incorrect do
      is_correct { false }
    end

    trait :with_multiple_values do
      answer_data { { "values" => %w[A C] } }
    end
  end
end

# == Schema Information
#
# Table name: attempt_answers
#
#  id                   :bigint           not null, primary key
#  answer_data          :json
#  answer_value         :text
#  is_correct           :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  challenge_attempt_id :integer          not null
#  field_id             :string(255)      not null
#
# Indexes
#
#  idx_attempt_answers_unique                     (challenge_attempt_id,field_id) UNIQUE
#  index_attempt_answers_on_challenge_attempt_id  (challenge_attempt_id)
#
# Foreign Keys
#
#  fk_rails_...  (challenge_attempt_id => challenge_attempts.id)
#




