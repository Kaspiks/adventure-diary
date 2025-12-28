# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    sequence(:name) { |n| "Location #{n}" }
    latitude { 40.7128 }
    longitude { -74.0060 }
    radius_meters { 100 }
    active { true }

    trait :central_park do
      name { "Central Park" }
      latitude { 40.7829 }
      longitude { -73.9654 }
      radius_meters { 500 }
    end

    trait :golden_gate do
      name { "Golden Gate Bridge" }
      latitude { 37.8199 }
      longitude { -122.4783 }
      radius_meters { 200 }
    end
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





