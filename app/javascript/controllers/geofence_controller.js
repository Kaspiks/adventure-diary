import { Controller } from "@hotwired/stimulus"

/**
 * Geofence Controller
 */
export default class extends Controller {
  static targets = [
    "map",           // Map container
    "status",        // Status message element
    "submitButton",  // Submit button to enable/disable
    "userLat",       // Hidden field for user latitude
    "userLng",       // Hidden field for user longitude
    "checkButton"    // Check location button
  ]

  static values = {
    latitude: Number,
    longitude: Number,
    radiusMeters: Number,
    locationName: String,
    geofenced: Boolean
  }

  connect() {
    this.map = null
    this.locationMarker = null
    this.userMarker = null
    this.radiusCircle = null
    this.userCircle = null
    this.userPosition = null
    this.isWithinRadius = false
    this.watchId = null

    if (this.geofencedValue) {
      this.initializeMap()
      this.disableSubmit()
      this.setStatus("checking", "Checking your location...")
      this.checkLocation()
    } else {
      this.enableSubmit()
    }
  }

  disconnect() {
    if (this.watchId !== null) {
      navigator.geolocation.clearWatch(this.watchId)
    }
    if (this.map) {
      this.map.remove()
      this.map = null
    }
  }

  initializeMap() {
    if (!this.hasMapTarget || typeof L === "undefined") return

    const lat = this.latitudeValue
    const lng = this.longitudeValue

    this.map = L.map(this.mapTarget, {
      scrollWheelZoom: true,
      zoomControl: true
    }).setView([lat, lng], 16)

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      maxZoom: 19
    }).addTo(this.map)

    this.locationMarker = L.marker([lat, lng]).addTo(this.map)
    this.locationMarker.bindPopup(`<b>${this.locationNameValue}</b><br>Target Location`)

    // Add radius circle
    if (this.radiusMetersValue > 0) {
      this.radiusCircle = L.circle([lat, lng], {
        radius: this.radiusMetersValue,
        color: "#10b981",
        fillColor: "#10b981",
        fillOpacity: 0.15,
        weight: 2
      }).addTo(this.map)

      this.map.fitBounds(this.radiusCircle.getBounds(), { padding: [20, 20] })
    }

    setTimeout(() => this.map.invalidateSize(), 100)
  }

  checkLocation() {
    if (!navigator.geolocation) {
      this.setStatus("error", "Geolocation is not supported by your browser")
      this.disableSubmit()
      return
    }

    // Get current position
    navigator.geolocation.getCurrentPosition(
      (position) => this.handlePositionSuccess(position),
      (error) => this.handlePositionError(error),
      {
        enableHighAccuracy: true,
        timeout: 15000,
        maximumAge: 30000
      }
    )
  }

  refreshLocation() {
    if (this.hasCheckButtonTarget) {
      this.checkButtonTarget.disabled = true
      this.checkButtonTarget.textContent = "Checking..."
    }
    this.setStatus("checking", "Updating your location...")
    this.checkLocation()
  }

  handlePositionSuccess(position) {
    const userLat = position.coords.latitude
    const userLng = position.coords.longitude
    const accuracy = position.coords.accuracy

    this.userPosition = { lat: userLat, lng: userLng, accuracy }

    if (this.hasUserLatTarget) {
      this.userLatTarget.value = userLat
    }
    if (this.hasUserLngTarget) {
      this.userLngTarget.value = userLng
    }

    this.updateUserMarker(userLat, userLng, accuracy)

    const distance = this.haversineDistance(
      userLat, userLng,
      this.latitudeValue, this.longitudeValue
    )

    this.isWithinRadius = distance <= this.radiusMetersValue

    if (this.isWithinRadius) {
      this.setStatus("success", `You are within the location area ✓`)
      this.enableSubmit()
    } else {
      const distanceFormatted = distance >= 1000 
        ? `${(distance / 1000).toFixed(1)} km` 
        : `${Math.round(distance)} m`
      this.setStatus("error", `You are ${distanceFormatted} away. Move closer to submit.`)
      this.disableSubmit()
    }

    if (this.hasCheckButtonTarget) {
      this.checkButtonTarget.disabled = false
      this.checkButtonTarget.textContent = "Refresh Location"
    }
  }

  handlePositionError(error) {
    let message = "Unable to get your location"
    
    switch (error.code) {
      case error.PERMISSION_DENIED:
        message = "Location permission denied. Please enable location access."
        break
      case error.POSITION_UNAVAILABLE:
        message = "Location unavailable. Please try again."
        break
      case error.TIMEOUT:
        message = "Location request timed out. Please try again."
        break
    }

    this.setStatus("error", message)
    this.disableSubmit()

    if (this.hasCheckButtonTarget) {
      this.checkButtonTarget.disabled = false
      this.checkButtonTarget.textContent = "Try Again"
    }
  }

  updateUserMarker(lat, lng, accuracy) {
    if (!this.map) return

    if (this.userMarker) {
      this.userMarker.remove()
    }
    if (this.userCircle) {
      this.userCircle.remove()
    }

    const userIcon = L.divIcon({
      className: "user-location-marker",
      html: `<div style="width:16px;height:16px;background:#3b82f6;border-radius:50%;border:3px solid white;box-shadow:0 2px 6px rgba(0,0,0,0.3);"></div>`,
      iconSize: [16, 16],
      iconAnchor: [8, 8]
    })

    this.userMarker = L.marker([lat, lng], { icon: userIcon }).addTo(this.map)
    this.userMarker.bindPopup("<b>Your Location</b>")

    if (accuracy && accuracy < 1000) {
      this.userCircle = L.circle([lat, lng], {
        radius: accuracy,
        color: "#3b82f6",
        fillColor: "#3b82f6",
        fillOpacity: 0.1,
        weight: 1
      }).addTo(this.map)
    }

    if (this.radiusCircle) {
      const group = L.featureGroup([this.radiusCircle, this.userMarker])
      this.map.fitBounds(group.getBounds(), { padding: [30, 30] })
    }
  }

  // Haversine formula for checking distance between two points
  haversineDistance(lat1, lng1, lat2, lng2) {
    const R = 6371000 // Earth's radius in meters
    const dLat = this.toRad(lat2 - lat1)
    const dLng = this.toRad(lng2 - lng1)
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(this.toRad(lat1)) * Math.cos(this.toRad(lat2)) *
              Math.sin(dLng / 2) * Math.sin(dLng / 2)
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    return R * c
  }

  toRad(deg) {
    return deg * (Math.PI / 180)
  }

  setStatus(type, message) {
    if (!this.hasStatusTarget) return

    this.statusTarget.textContent = message
    this.statusTarget.classList.remove("hidden", "text-emerald-400", "text-red-400", "text-amber-400", "text-slate-400")

    switch (type) {
      case "success":
        this.statusTarget.classList.add("text-emerald-400")
        break
      case "error":
        this.statusTarget.classList.add("text-red-400")
        break
      case "checking":
        this.statusTarget.classList.add("text-amber-400")
        break
      default:
        this.statusTarget.classList.add("text-slate-400")
    }
  }

  enableSubmit() {
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
      this.submitButtonTarget.classList.add("cursor-pointer")
    }
  }

  disableSubmit() {
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
      this.submitButtonTarget.classList.remove("cursor-pointer")
    }
  }
}
