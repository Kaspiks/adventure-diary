# frozen_string_literal: true

# Haversine distance calculator for geolocation
# Calculates the great-circle distance between two points on Earth
module GeoDistance
  EARTH_RADIUS_METERS = 6_371_000.0

  class << self
    # Calculate distance in meters between two coordinates
    # @param lat1 [Float] Latitude of point 1 in degrees
    # @param lng1 [Float] Longitude of point 1 in degrees
    # @param lat2 [Float] Latitude of point 2 in degrees
    # @param lng2 [Float] Longitude of point 2 in degrees
    # @return [Float] Distance in meters
    def haversine(lat1, lng1, lat2, lng2)
      return 0.0 if lat1 == lat2 && lng1 == lng2

      lat1_rad = degrees_to_radians(lat1)
      lat2_rad = degrees_to_radians(lat2)
      delta_lat = degrees_to_radians(lat2 - lat1)
      delta_lng = degrees_to_radians(lng2 - lng1)

      # Haversine formula
      a = Math.sin(delta_lat / 2)**2 +
          Math.cos(lat1_rad) * Math.cos(lat2_rad) *
          Math.sin(delta_lng / 2)**2

      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

      EARTH_RADIUS_METERS * c
    end

    # Check if a point is within a radius of another point
    # @param user_lat [Float] User's latitude
    # @param user_lng [Float] User's longitude
    # @param target_lat [Float] Target latitude
    # @param target_lng [Float] Target longitude
    # @param radius_meters [Integer] Allowed radius in meters
    # @return [Boolean] True if within radius
    def within_radius?(user_lat, user_lng, target_lat, target_lng, radius_meters)
      return false unless valid_coordinates?(user_lat, user_lng)
      return false unless valid_coordinates?(target_lat, target_lng)
      return false unless radius_meters.to_i.positive?

      distance = haversine(user_lat, user_lng, target_lat, target_lng)
      distance <= radius_meters.to_f
    end

    def valid_coordinates?(lat, lng)
      return false if lat.nil? || lng.nil?

      lat_f = lat.to_f
      lng_f = lng.to_f

      lat_f >= -90 && lat_f <= 90 && lng_f >= -180 && lng_f <= 180
    end

    private

    def degrees_to_radians(degrees)
      degrees.to_f * Math::PI / 180.0
    end
  end
end
