# frozen_string_literal: true

require "rails_helper"

RSpec.describe Location, "geofencing" do
  describe "#geofenced?" do
    it "returns true when location has coordinates and radius" do
      location = build(:location, latitude: 51.5, longitude: -0.1, radius_meters: 100)
      expect(location.geofenced?).to be true
    end

    it "returns false when latitude is nil" do
      location = build(:location, latitude: nil, longitude: -0.1, radius_meters: 100)
      expect(location.geofenced?).to be false
    end

    it "returns false when longitude is nil" do
      location = build(:location, latitude: 51.5, longitude: nil, radius_meters: 100)
      expect(location.geofenced?).to be false
    end

    it "returns false when radius is nil" do
      location = build(:location, latitude: 51.5, longitude: -0.1, radius_meters: nil)
      expect(location.geofenced?).to be false
    end

    it "returns false when radius is zero" do
      location = build(:location, latitude: 51.5, longitude: -0.1, radius_meters: 0)
      expect(location.geofenced?).to be false
    end
  end

  describe "#distance_from" do
    let(:location) { build(:location, latitude: 51.5074, longitude: -0.1278, radius_meters: 100) }

    it "returns distance in meters" do
      distance = location.distance_from(51.5074, -0.1278)
      expect(distance).to eq(0.0)
    end

    it "returns nil when location is not geofenced" do
      location.radius_meters = nil
      expect(location.distance_from(51.5, -0.1)).to be_nil
    end
  end

  describe "#within_radius?" do
    let(:location) { build(:location, latitude: 51.5074, longitude: -0.1278, radius_meters: 100) }

    it "returns true when user is at the exact location" do
      expect(location.within_radius?(51.5074, -0.1278)).to be true
    end

    it "returns true when user is within radius" do
      # Point about 50 meters away
      expect(location.within_radius?(51.5078, -0.1278)).to be true
    end

    it "returns false when user is outside radius" do
      # Point about 1 km away
      expect(location.within_radius?(51.515, -0.1278)).to be false
    end

    it "returns true when location is not geofenced" do
      location.radius_meters = nil
      expect(location.within_radius?(0, 0)).to be true
    end
  end

  describe "#to_geofence_json" do
    let(:location) { create(:location, :central_park) }

    it "returns geofence data as hash" do
      json = location.to_geofence_json
      
      expect(json[:id]).to eq(location.id)
      expect(json[:name]).to eq("Central Park")
      expect(json[:latitude]).to be_a(Float)
      expect(json[:longitude]).to be_a(Float)
      expect(json[:radius_meters]).to eq(500)
      expect(json[:geofenced]).to be true
    end
  end
end
