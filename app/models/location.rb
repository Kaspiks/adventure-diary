# frozen_string_literal: true

class Location < ApplicationRecord
  has_many :challenges, dependent: :nullify

  validates :name, presence: true, length: { maximum: 255 }

  scope :ordered, -> { order(:name) }

  searchable_text_column :name
end

# == Schema Information
#
# Table name: locations
#
#  id            :integer          not null, primary key
#  latitude      :decimal(10, 7)
#  longitude     :decimal(10, 7)
#  name          :string(255)      not null
#  radius_meters :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_locations_on_name  (name)
#
