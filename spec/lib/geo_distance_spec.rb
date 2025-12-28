# frozen_string_literal: true

require "rails_helper"

RSpec.describe GeoDistance do
  describe ".haversine" do
    it "returns 0 for same coordinates" do
      expect(described_class.haversine(51.5, -0.1, 51.5, -0.1)).to eq(0.0)
    end

    it "calculates distance between London and Paris (approx 344 km)" do
      # London: 51.5074, -0.1278
      # Paris: 48.8566, 2.3522
      distance = described_class.haversine(51.5074, -0.1278, 48.8566, 2.3522)
      # Distance should be approximately 344 km
      expect(distance).to be_within(5000).of(344_000)
    end

    it "calculates short distances accurately" do
      # Two points ~100 meters apart
      lat1 = 51.5074
      lng1 = -0.1278
      lat2 = 51.5083
      lng2 = -0.1278
      
      distance = described_class.haversine(lat1, lng1, lat2, lng2)
      expect(distance).to be_within(10).of(100)
    end
  end

  describe ".within_radius?" do
    let(:target_lat) { 51.5074 }
    let(:target_lng) { -0.1278 }
    let(:radius) { 100 }

    it "returns true when user is within radius" do
      # Point very close to target
      expect(described_class.within_radius?(51.5074, -0.1278, target_lat, target_lng, radius)).to be true
    end

    it "returns false when user is outside radius" do
      # Point about 1km away
      expect(described_class.within_radius?(51.515, -0.1278, target_lat, target_lng, radius)).to be false
    end

    it "returns false for invalid coordinates" do
      expect(described_class.within_radius?(nil, nil, target_lat, target_lng, radius)).to be false
      expect(described_class.within_radius?(100, 200, target_lat, target_lng, radius)).to be false
    end

    it "returns false for zero or negative radius" do
      expect(described_class.within_radius?(51.5074, -0.1278, target_lat, target_lng, 0)).to be false
      expect(described_class.within_radius?(51.5074, -0.1278, target_lat, target_lng, -100)).to be false
    end
  end

  describe ".valid_coordinates?" do
    it "returns true for valid coordinates" do
      expect(described_class.valid_coordinates?(51.5, -0.1)).to be true
      expect(described_class.valid_coordinates?(0, 0)).to be true
      expect(described_class.valid_coordinates?(-90, -180)).to be true
      expect(described_class.valid_coordinates?(90, 180)).to be true
    end

    it "returns false for invalid coordinates" do
      expect(described_class.valid_coordinates?(nil, nil)).to be false
      expect(described_class.valid_coordinates?(91, 0)).to be false
      expect(described_class.valid_coordinates?(0, 181)).to be false
      expect(described_class.valid_coordinates?(-91, 0)).to be false
    end
  end
end
