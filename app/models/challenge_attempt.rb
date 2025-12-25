# frozen_string_literal: true

class ChallengeAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :challenge
  belongs_to :attempt_status
  belongs_to :reviewer_user, class_name: "User", optional: true

  has_many :attempt_artifacts, dependent: :destroy
  has_many :attempt_answers, dependent: :destroy

  def answer_for_field(field_id)
    attempt_answers.find_by(field_id: field_id.to_s)
  end

  def photos_for_field(field_id)
    attempt_artifacts.photos.for_field(field_id.to_s)
  end

  def validate_submission
    return true if challenge.fields.empty?

    challenge.fields.each do |field|
      next unless field.required

      case field.type
      when "photo_upload"
        photos_count = photos_for_field(field.id).count
        if photos_count < 1
          errors.add(:base, "#{field.label} requires at least 1 photo")
        end
      when "text_input", "single_choice", "hidden_letter"
        answer = answer_for_field(field.id)
        if answer.blank? || answer.answer_value.blank?
          errors.add(:base, "#{field.label} is required")
        end
      when "multiple_choice"
        answer = answer_for_field(field.id)
        if answer.blank? || answer.answer_value_array.empty?
          errors.add(:base, "#{field.label} is required")
        end
      end
    end

    errors.empty?
  end

  validates :started_at, presence: true
  validates :evidence_url, length: { maximum: 500 }

  scope :ordered, -> { order(created_at: :desc) }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_challenge, ->(challenge) { where(challenge: challenge) }
  scope :non_final, -> { joins(:attempt_status).where(attempt_statuses: { is_final: false }) }
  scope :pending_review, -> { joins(:attempt_status).where(attempt_statuses: { code: AttemptStatus::SUBMITTED }) }

  def started?
    attempt_status&.code == AttemptStatus::STARTED
  end

  def submitted?
    attempt_status&.code == AttemptStatus::SUBMITTED
  end

  def approved?
    attempt_status&.code == AttemptStatus::APPROVED
  end

  def rejected?
    attempt_status&.code == AttemptStatus::REJECTED
  end

  def final?
    attempt_status&.is_final?
  end

  def owned_by?(user)
    user_id == user.id
  end

  def can_submit?
    started? && !final?
  end

  def can_review?
    submitted? && !final?
  end

  def calculate_score
    return 0 unless challenge.has_fields?

    challenge.fields.sum do |field|
      answer = answer_for_field(field.id)
      if answer
        answer.is_correct ? field.points : 0
      else
        0
      end
    end
  end

  def all_responses_correct?
    return true unless challenge.has_fields?

    challenge.fields.all? do |field|
      next true unless field.required

      answer = answer_for_field(field.id)
      answer&.is_correct || false
    end
  end

  def response_results
    return [] unless challenge.has_fields?

    challenge.fields.map do |field|
      answer = answer_for_field(field.id)
      response_value = answer&.answer_value
      is_correct = answer&.is_correct || false
      
      {
        field_id: field.id,
        label: field.label,
        type: field.type,
        response: response_value,
        is_correct: is_correct,
        points_earned: is_correct ? field.points : 0,
        max_points: field.points
      }
    end
  end

  def photos
    attempt_artifacts.photos
  end
end

# == Schema Information
#
# Table name: challenge_attempts
#
#  id                :integer          not null, primary key
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
#  attempt_status_id  (attempt_status_id => attempt_statuses.id)
#  challenge_id       (challenge_id => challenges.id)
#  reviewer_user_id   (reviewer_user_id => users.id)
#  user_id            (user_id => users.id)
#
