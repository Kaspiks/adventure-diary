# frozen_string_literal: true

class AttemptAnswer < ApplicationRecord
  belongs_to :challenge_attempt

  validates :field_id, presence: true

  def answer_value_array
    answer_data['values'] || [answer_value].compact
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
