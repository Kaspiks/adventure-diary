# frozen_string_literal: true

class Classification < ApplicationRecord
  has_many :classification_values, dependent: :destroy

  validates :code, uniqueness: true
  validates :code, presence: true

  validates_lengths_from_database
end

# == Schema Information
#
# Table name: classifications(Classifications)
#
#  id                                                                  :bigint           not null, primary key
#  code(Classification code)                                           :string(255)      not null
#  system(Check whether the classification is a system classification) :boolean          default(FALSE)
#  created_at                                                          :datetime         not null
#  updated_at                                                          :datetime         not null
#
# Indexes
#
#  index_classifications_on_code  (code) UNIQUE
#
