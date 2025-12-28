# frozen_string_literal: true

class AwardPointLevel < ApplicationRecord
  has_many :challenges, dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :name, presence: true, length: { maximum: 100 }
  validates :points, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:points) }
end

# == Schema Information
#
# Table name: award_point_levels
#
#  id          :bigint           not null, primary key
#  code        :string(50)       not null
#  description :text
#  name        :string(100)      not null
#  points      :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_award_point_levels_on_code  (code) UNIQUE
#
