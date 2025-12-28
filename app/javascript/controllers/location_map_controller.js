import { Controller } from "@hotwired/stimulus"

// Leaflet is loaded via script tag in layout and available as global `L`

/**
 * Leaflet Map Controller for Location Form
 * 
 * Provides interactive map functionality for selecting and viewing locations.
 * Supports both coordinate input and map-based selection modes.
 * 
 * Usage:
 *   Add data-controller="location-map" to your form container
 *   Add data-location-map-target attributes to your form inputs
 */
export default class extends Controller {
  static targets = [
    "container",      // Map container element
    "name",           // Name input field
    "latitude",       // Latitude input field
    "longitude",      // Longitude input field
    "radius",         // Radius input field
    "status",         // Status message element
    "modeToggle",     // Mode toggle button
    "suggestName"     // Suggest name button (shown after reverse geocode)
  ]

  static values = {
    defaultLat: { type: Number, default: 51.505 },
    defaultLng: { type: Number, default: -0.09 },
    defaultZoom: { type: Number, default: 2 },
    locationZoom: { type: Number, default: 15 },
    tileUrl: { type: String, default: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" },
    attribution: { type: String, default: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors' }
  }

  connect() {
    this.map = null
    this.marker = null
    this.circle = null
    this.pickMode = false
    this.nameManuallyEdited = false
    this.suggestedName = null
    this.geocodeAbortController = null
    this.geocodeDebounceTimer = null
    this.coordinateDebounceTimer = null
    
    // Delay initialization to ensure DOM is ready
    requestAnimationFrame(() => {
      this.initializeMap()
      this.bindInputListeners()
      this.loadInitialState()
    })
  }

  disconnect() {
    this.clearTimers()
    if (this.geocodeAbortController) {
      this.geocodeAbortController.abort()
    }
    if (this.map) {
      this.map.remove()
      this.map = null
    }
  }

  initializeMap() {
    if (!this.hasContainerTarget) return

    this.map = L.map(this.containerTarget, {
      scrollWheelZoom: true,
      zoomControl: true
    }).setView([this.defaultLatValue, this.defaultLngValue], this.defaultZoomValue)

    L.tileLayer(this.tileUrlValue, {
      attribution: this.attributionValue,
      maxZoom: 19
    }).addTo(this.map)

    this.map.on("click", (e) => this.handleMapClick(e))

    setTimeout(() => {
      this.map.invalidateSize()
    }, 100)
  }

  loadInitialState() {
    const lat = this.parseCoordinate(this.latitudeTarget?.value, -90, 90)
    const lng = this.parseCoordinate(this.longitudeTarget?.value, -180, 180)
    const radius = this.parseRadius(this.radiusTarget?.value)

    if (lat !== null && lng !== null) {
      this.setMarker(lat, lng, false)
      this.map.setView([lat, lng], this.locationZoomValue)
      
      if (radius !== null) {
        this.setCircle(lat, lng, radius)
      }
    }

    if (this.hasNameTarget && this.nameTarget.value.trim()) {
      this.nameManuallyEdited = true
    }
  }

  bindInputListeners() {
    if (this.hasNameTarget) {
      this.nameTarget.addEventListener("input", () => {
        this.nameManuallyEdited = true
        this.hideSuggestName()
        this.debounceGeocode()
      })
    }

    if (this.hasLatitudeTarget) {
      this.latitudeTarget.addEventListener("input", () => this.debounceCoordinateUpdate())
    }
    if (this.hasLongitudeTarget) {
      this.longitudeTarget.addEventListener("input", () => this.debounceCoordinateUpdate())
    }

    if (this.hasRadiusTarget) {
      this.radiusTarget.addEventListener("input", () => this.updateCircleFromInput())
    }
  }
  
  toggleMode() {
    this.pickMode = !this.pickMode
    this.updateModeUI()
    
    if (this.marker) {
      if (this.pickMode) {
        this.marker.dragging.enable()
      } else {
        this.marker.dragging.disable()
      }
    }

    this.setStatus(this.pickMode ? "Click on the map or drag the marker to set location" : "")
  }

  updateModeUI() {
    if (this.hasModeToggleTarget) {
      const btn = this.modeToggleTarget
      if (this.pickMode) {
        btn.classList.add("bg-emerald-600", "text-white")
        btn.classList.remove("bg-slate-700", "text-slate-300")
        btn.textContent = "Exit Pick Mode"
      } else {
        btn.classList.remove("bg-emerald-600", "text-white")
        btn.classList.add("bg-slate-700", "text-slate-300")
        btn.textContent = "Pick on Map"
      }
    }
  }

  handleMapClick(e) {
    if (!this.pickMode) return

    const { lat, lng } = e.latlng
    this.setMarker(lat, lng, true)
    this.updateInputs(lat, lng)
    this.reverseGeocode(lat, lng)
  }

  setMarker(lat, lng, draggable = false) {
    if (!this.map) return

    if (this.marker) {
      this.marker.setLatLng([lat, lng])
      if (draggable || this.pickMode) {
        this.marker.dragging.enable()
      } else {
        this.marker.dragging.disable()
      }
    } else {
      this.marker = L.marker([lat, lng], {
        draggable: draggable || this.pickMode
      }).addTo(this.map)

      this.marker.on("dragend", (e) => {
        const pos = e.target.getLatLng()
        this.updateInputs(pos.lat, pos.lng)
        this.updateCircle(pos.lat, pos.lng)
        this.reverseGeocode(pos.lat, pos.lng)
      })
    }

    this.updateCircle(lat, lng)
  }

  setCircle(lat, lng, radius) {
    if (!this.map) return

    if (this.circle) {
      this.circle.setLatLng([lat, lng])
      this.circle.setRadius(radius)
    } else {
      this.circle = L.circle([lat, lng], {
        radius: radius,
        color: "#10b981",
        fillColor: "#10b981",
        fillOpacity: 0.2,
        weight: 2
      }).addTo(this.map)
    }
  }

  updateCircle(lat, lng) {
    if (this.circle) {
      this.circle.setLatLng([lat, lng])
    }
  }

  removeCircle() {
    if (this.circle) {
      this.circle.remove()
      this.circle = null
    }
  }

  updateCircleFromInput() {
    const radius = this.parseRadius(this.radiusTarget?.value)
    
    if (radius === null) {
      this.removeCircle()
      return
    }

    if (this.marker) {
      const pos = this.marker.getLatLng()
      this.setCircle(pos.lat, pos.lng, radius)
    }
  }

  updateInputs(lat, lng) {
    if (this.hasLatitudeTarget) {
      this.latitudeTarget.value = lat.toFixed(7)
      this.latitudeTarget.dispatchEvent(new Event("change", { bubbles: true }))
    }
    if (this.hasLongitudeTarget) {
      this.longitudeTarget.value = lng.toFixed(7)
      this.longitudeTarget.dispatchEvent(new Event("change", { bubbles: true }))
    }
  }

  debounceCoordinateUpdate() {
    clearTimeout(this.coordinateDebounceTimer)
    this.coordinateDebounceTimer = setTimeout(() => {
      this.updateMapFromInputs()
    }, 300)
  }

  updateMapFromInputs() {
    const lat = this.parseCoordinate(this.latitudeTarget?.value, -90, 90)
    const lng = this.parseCoordinate(this.longitudeTarget?.value, -180, 180)

    if (lat === null || lng === null) {
      return
    }

    this.setMarker(lat, lng, this.pickMode)
    this.map.setView([lat, lng], Math.max(this.map.getZoom(), this.locationZoomValue))

    const radius = this.parseRadius(this.radiusTarget?.value)
    if (radius !== null) {
      this.setCircle(lat, lng, radius)
    }
  }

  debounceGeocode() {
    clearTimeout(this.geocodeDebounceTimer)
    this.geocodeDebounceTimer = setTimeout(() => {
      this.geocodeName()
    }, 600)
  }

  async geocodeName() {
    if (!this.hasNameTarget) return

    const name = this.nameTarget.value.trim()
    
    if (name.length < 3) {
      this.setStatus("")
      return
    }

    if (this.geocodeAbortController) {
      this.geocodeAbortController.abort()
    }
    this.geocodeAbortController = new AbortController()

    this.setStatus("Searching...")

    try {
      const response = await fetch(
        `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(name)}&limit=1`,
        {
          headers: {
            "Accept": "application/json",
            "User-Agent": "AdventureDiary/1.0"
          },
          signal: this.geocodeAbortController.signal
        }
      )

      if (!response.ok) {
        throw new Error("Geocoding failed")
      }

      const results = await response.json()

      if (results.length > 0) {
        const result = results[0]
        const lat = parseFloat(result.lat)
        const lng = parseFloat(result.lon)

        this.setMarker(lat, lng, this.pickMode)
        this.map.setView([lat, lng], this.locationZoomValue)
        this.updateInputs(lat, lng)
        
        this.setStatus(`Found: ${result.display_name.substring(0, 50)}...`)
        setTimeout(() => this.setStatus(""), 3000)
      } else {
        this.setStatus("No results found")
        setTimeout(() => this.setStatus(""), 3000)
      }
    } catch (error) {
      if (error.name !== "AbortError") {
        this.setStatus("Search failed")
        setTimeout(() => this.setStatus(""), 3000)
      }
    }
  }

  async reverseGeocode(lat, lng) {
    if (this.geocodeAbortController) {
      this.geocodeAbortController.abort()
    }
    this.geocodeAbortController = new AbortController()

    try {
      const response = await fetch(
        `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}`,
        {
          headers: {
            "Accept": "application/json",
            "User-Agent": "AdventureDiary/1.0"
          },
          signal: this.geocodeAbortController.signal
        }
      )

      if (!response.ok) return

      const result = await response.json()

      if (result && result.display_name) {
        const shortName = result.name || 
                          result.address?.tourism ||
                          result.address?.building ||
                          result.address?.road ||
                          result.display_name.split(",")[0]

        this.suggestedName = shortName

        if (!this.nameManuallyEdited || !this.nameTarget.value.trim()) {
          this.nameTarget.value = shortName
          this.nameTarget.dispatchEvent(new Event("change", { bubbles: true }))
          this.nameManuallyEdited = false
        } else {
          this.showSuggestName(shortName)
        }
      }
    } catch (error) {
    }
  }

  showSuggestName(name) {
    if (this.hasSuggestNameTarget) {
      this.suggestNameTarget.classList.remove("hidden")
      this.suggestNameTarget.querySelector("[data-suggested-name]")?.setAttribute("data-suggested-name", name)
      const nameSpan = this.suggestNameTarget.querySelector(".suggested-name-text")
      if (nameSpan) {
        nameSpan.textContent = name
      }
    }
  }

  hideSuggestName() {
    if (this.hasSuggestNameTarget) {
      this.suggestNameTarget.classList.add("hidden")
    }
  }

  useSuggestedName() {
    if (this.suggestedName && this.hasNameTarget) {
      this.nameTarget.value = this.suggestedName
      this.nameTarget.dispatchEvent(new Event("change", { bubbles: true }))
      this.hideSuggestName()
    }
  }

  parseCoordinate(value, min, max) {
    if (!value || value.trim() === "") return null
    
    const num = parseFloat(value)
    if (isNaN(num)) return null
    
    return Math.max(min, Math.min(max, num))
  }

  parseRadius(value) {
    if (!value || value.trim() === "") return null
    
    const num = parseInt(value, 10)
    if (isNaN(num) || num <= 0) return null
    
    return num
  }

  setStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
      if (message) {
        this.statusTarget.classList.remove("hidden")
      } else {
        this.statusTarget.classList.add("hidden")
      }
    }
  }

  clearTimers() {
    clearTimeout(this.geocodeDebounceTimer)
    clearTimeout(this.coordinateDebounceTimer)
  }

  centerOnMarker() {
    if (this.marker && this.map) {
      this.map.setView(this.marker.getLatLng(), this.locationZoomValue)
    }
  }
}

