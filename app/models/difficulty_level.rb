# frozen_string_literal: true

class DifficultyLevel < ApplicationRecord
  has_many :challenges, dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :name, presence: true, length: { maximum: 100 }

  scope :ordered, -> { order(:sort_order, :name) }
end

# == Schema Information
#
# Table name: difficulty_levels
#
#  id          :bigint           not null, primary key
#  code        :string(50)       not null
#  description :text
#  name        :string(100)      not null
#  sort_order  :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_difficulty_levels_on_code        (code) UNIQUE
#  index_difficulty_levels_on_sort_order  (sort_order)
#
