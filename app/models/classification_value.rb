# frozen_string_literal: true

class ClassificationValue < ApplicationRecord
  belongs_to :classification

  validates :value, presence: true

  validates_lengths_from_database

  scope :active, -> { where(active: true) }

  searchable_text_column :value

  class << self
    def by_classification_code(code)
      joins(:classification).merge(Classification.where(code: code))
    end
  end
end

# == Schema Information
#
# Table name: classification_values
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
