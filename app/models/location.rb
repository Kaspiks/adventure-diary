# frozen_string_literal: true

class Location < ApplicationRecord
  has_many :challenges, dependent: :nullify

  validates :name, presence: true, length: { maximum: 255 }

  scope :ordered, -> { order(:name) }
  scope :active, -> { where(active: true) }

  searchable_text_column :name

  def geofenced?
    latitude.present? && longitude.present? && radius_meters.to_i.positive?
  end

  def distance_from(user_lat, user_lng)
    return nil unless geofenced?

    GeoDistance.haversine(user_lat.to_f, user_lng.to_f, latitude.to_f, longitude.to_f)
  end

  def within_radius?(user_lat, user_lng)
    return true unless geofenced?

    GeoDistance.within_radius?(
      user_lat.to_f, user_lng.to_f,
      latitude.to_f, longitude.to_f,
      radius_meters
    )
  end

  def to_geofence_json
    {
      id: id,
      name: name,
      latitude: latitude&.to_f,
      longitude: longitude&.to_f,
      radius_meters: radius_meters,
      geofenced: geofenced?
    }
  end
end

# == Schema Information
#
# Table name: locations
#
#  id            :bigint           not null, primary key
#  active        :boolean          default(TRUE), not null
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
