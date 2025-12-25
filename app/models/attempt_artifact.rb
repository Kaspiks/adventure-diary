# frozen_string_literal: true

class AttemptArtifact < ApplicationRecord
  belongs_to :challenge_attempt
  has_one_attached :file

  validates :kind, presence: true, inclusion: { in: %w[photo video] }
  validates :file, presence: true

  scope :photos, -> { where(kind: 'photo') }
  scope :videos, -> { where(kind: 'video') }
  scope :for_field, ->(field_id) { where(field_id: field_id) }

  def photo?
    kind == 'photo'
  end

  def video?
    kind == 'video'
  end
end

# == Schema Information
#
# Table name: attempt_artifacts
#
#  id                   :integer          not null, primary key
#  kind                 :string(50)       not null
#  metadata             :json
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  challenge_attempt_id :integer          not null
#  field_id             :string(255)
#
# Indexes
#
#  index_attempt_artifacts_on_challenge_attempt_id               (challenge_attempt_id)
#  index_attempt_artifacts_on_challenge_attempt_id_and_field_id  (challenge_attempt_id,field_id)
#  index_attempt_artifacts_on_challenge_attempt_id_and_kind      (challenge_attempt_id,kind)
#
# Foreign Keys
#
#  challenge_attempt_id  (challenge_attempt_id => challenge_attempts.id)
#
