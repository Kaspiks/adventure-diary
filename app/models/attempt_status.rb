# frozen_string_literal: true

class AttemptStatus < ApplicationRecord
  STARTED = "started"
  SUBMITTED = "submitted"
  APPROVED = "approved"
  REJECTED = "rejected"

  has_many :challenge_attempts, dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :name, presence: true, length: { maximum: 100 }

  scope :ordered, -> { order(:name) }
  scope :final, -> { where(is_final: true) }

  class << self
    def started
      find_by(code: STARTED)
    end

    def submitted
      find_by(code: SUBMITTED)
    end

    def approved
      find_by(code: APPROVED)
    end

    def rejected
      find_by(code: REJECTED)
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
