# frozen_string_literal: true

class ChallengeType < ApplicationRecord
  has_many :challenges, dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :name, presence: true, length: { maximum: 100 }

  scope :ordered, -> { order(:name) }
end

# == Schema Information
#
# Table name: challenge_types
#
#  id          :integer          not null, primary key
#  code        :string(50)       not null
#  description :text
#  name        :string(100)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_challenge_types_on_code  (code) UNIQUE
#
