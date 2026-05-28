import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "map", "passFilter", "regionFilter", "depthFilter", "snowFilter",
    "openFilter", "resultCount", "emptyState",
    "selectedCard", "insights"
  ]

  static values = {
    resorts: Array
  }

  connect() {
    this.markers = new Map()
    this.labelMode = "conditions_score"
    this.resetFilters()
    this.filteredResorts = [...this.resortsValue]
    this.initializeWhenLeafletIsReady()
    this.handleResize = () => this.refreshMapSize()
    window.addEventListener("resize", this.handleResize)
  }

  disconnect() {
    if (this.handleResize) window.removeEventListener("resize", this.handleResize)
  }

  initializeWhenLeafletIsReady(attempt = 0) {
    if (this.map) {
      this.refreshMapSize()
      return
    }

    if (window.L) {
      this.initializeMap()
      return
    }

    if (attempt > 20) {
      this.initializeFallbackMap()
      return
    }

    window.setTimeout(() => this.initializeWhenLeafletIsReady(attempt + 1), 100)
  }

  initializeMap() {
    this.map = window.L.map(this.mapTarget, {
      scrollWheelZoom: true,
      zoomControl: true,
      attributionControl: false
    })

    window.L.control.attribution({ prefix: false }).addTo(this.map)

    window.L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 18,
      attribution: "&copy; OpenStreetMap contributors"
    }).addTo(this.map)

    this.map.setView([39.5, -98.35], 4)
    this.renderMarkers(this.filteredResorts)
    this.fitToResorts(this.filteredResorts)
    this.updateInsights(this.filteredResorts)
    this.updateResultCount(this.filteredResorts.length)
    this.refreshMapSize()
  }

  applyFilters() {
    this.filteredResorts = this.resortsValue.filter((resort) => {
      const passValue = this.passFilterTarget.value
      const regionValue = this.regionFilterTarget.value
      const minimumDepth = Number(this.depthFilterTarget.value)
      const minimumSnow = Number(this.snowFilterTarget.value)
      const openOnly = this.openFilterTarget.checked

      const passMatches = passValue === "all" || resort.pass_types.includes(passValue) || resort.pass_type === passValue
      const regionMatches = regionValue === "all" || resort.region === regionValue
      const depthMatches = Number(resort.snow_depth_inches || 0) >= minimumDepth
      const snowMatches = Number(resort.forecast_snow_7d_inches || 0) >= minimumSnow
      const openMatches = !openOnly || resort.open_status === "open"

      return passMatches && regionMatches && depthMatches && snowMatches && openMatches
    })

    this.renderMarkers(this.filteredResorts)
    this.fitToResorts(this.filteredResorts)
    this.updateInsights(this.filteredResorts)
    this.updateResultCount(this.filteredResorts.length)
    this.emptyStateTarget.hidden = this.filteredResorts.length > 0
    this.refreshMapSize()
  }

  clearFilters() {
    this.resetFilters()
    this.applyFilters()
  }

  resetFilters() {
    this.passFilterTarget.value = "all"
    this.regionFilterTarget.value = "all"
    this.depthFilterTarget.value = "0"
    this.snowFilterTarget.value = "0"
    this.openFilterTarget.checked = false
  }

  refreshMapSize() {
    if (!this.map) return

    const refresh = () => {
      this.map.invalidateSize()
      this.fitToResorts(this.filteredResorts)
    }

    window.requestAnimationFrame(refresh)
    window.setTimeout(refresh, 150)
  }

  changeLabelMode(event) {
    this.labelMode = event.target.value
    this.renderMarkers(this.filteredResorts || this.resortsValue)
  }

  renderMarkers(resorts) {
    if (this.fallbackMap) {
      this.renderFallbackMarkers(resorts)
      return
    }

    if (!this.map) return

    this.markers.forEach((marker) => marker.remove())
    this.markers.clear()

    resorts.forEach((resort) => {
      const marker = window.L.marker([resort.latitude, resort.longitude], {
        icon: this.markerIcon(resort),
        title: resort.name
      }).addTo(this.map)

      marker.bindPopup(this.popupHtml(resort), {
        className: "snowwise-popup",
        maxWidth: 320
      })

      marker.on("click", () => this.selectResort(resort))
      this.markers.set(resort.id, marker)
    })
  }

  initializeFallbackMap() {
    this.fallbackMap = true
    this.mapTarget.innerHTML = `
      <div class="fallback-map-surface" aria-label="Approximate resort marker map">
        <div class="fallback-map-grid"></div>
        <div class="fallback-map-markers"></div>
      </div>
    `
    this.renderFallbackMarkers(this.filteredResorts)
    this.updateInsights(this.filteredResorts)
    this.updateResultCount(this.filteredResorts.length)
  }

  renderFallbackMarkers(resorts) {
    const markerLayer = this.mapTarget.querySelector(".fallback-map-markers")
    if (!markerLayer) return

    markerLayer.innerHTML = resorts.map((resort) => {
      const position = this.projectFallbackPosition(resort)
      return `
        <button
          type="button"
          class="fallback-map-marker"
          style="left: ${position.x}%; top: ${position.y}%;"
          title="${this.escapeAttribute(resort.name)}"
          data-resort-id="${resort.id}">
          <span class="snowwise-pin ${this.markerColorClass(resort)}"><span>${this.markerLabel(resort)}</span></span>
        </button>
      `
    }).join("")

    markerLayer.querySelectorAll("[data-resort-id]").forEach((marker) => {
      const resort = resorts.find((candidate) => String(candidate.id) === marker.dataset.resortId)
      if (resort) marker.addEventListener("click", () => this.selectResort(resort))
    })
  }

  projectFallbackPosition(resort) {
    const longitude = Number(resort.longitude)
    const latitude = Number(resort.latitude)
    const x = ((longitude + 180) / 360) * 100
    const y = ((90 - latitude) / 180) * 100

    return {
      x: Math.min(96, Math.max(4, x)),
      y: Math.min(92, Math.max(8, y))
    }
  }

  fitToResorts(resorts) {
    if (!this.map || resorts.length === 0) return

    const bounds = window.L.latLngBounds(resorts.map((resort) => [resort.latitude, resort.longitude]))
    this.map.fitBounds(bounds, { padding: [42, 42], maxZoom: 8 })
  }

  markerIcon(resort) {
    return window.L.divIcon({
      className: "snowwise-pin-icon",
      html: `<span class="snowwise-pin ${this.markerColorClass(resort)}"><span>${this.markerLabel(resort)}</span></span>`,
      iconSize: [34, 46],
      iconAnchor: [17, 46],
      popupAnchor: [0, -42]
    })
  }

  markerLabel(resort) {
    if (this.labelMode === "current_temperature") return `${Math.round(resort.current_temperature)}&deg;`
    if (this.labelMode === "seven_day_snowfall_total") return `${Math.round(resort.forecast_snow_7d_inches)}&quot;`

    return resort.conditions_score == null ? "--" : Math.round(resort.conditions_score)
  }

  markerColorClass(resort) {
    if (this.labelMode === "current_temperature") {
      return this.temperaturePinClass(resort.current_temperature)
    }

    if (this.labelMode === "seven_day_snowfall_total") {
      return this.sevenDaySnowPinClass(resort)
    }

    return `snowwise-pin--${resort.condition_quality}`
  }

  temperaturePinClass(temperature) {
    const value = Number(temperature)
    if (Number.isNaN(value)) return "snowwise-pin--unavailable"
    if (value < 32) return "snowwise-pin--temp-freezing"
    if (value >= 50) return "snowwise-pin--temp-hot"

    return "snowwise-pin--temp-moderate"
  }

  sevenDaySnowPinClass(resort) {
    const value = Number(resort.forecast_snow_7d_inches)
    if (!resort.forecast_snow_expected || Number.isNaN(value) || value <= 0) return "snowwise-pin--snow-none"
    if (value < 3) return "snowwise-pin--snow-light"
    if (value <= 6) return "snowwise-pin--snow-medium"

    return "snowwise-pin--snow-heavy"
  }

  selectResort(resort) {
    this.selectedCardTarget.innerHTML = this.selectedCardHtml(resort)
  }

  popupHtml(resort) {
    return `
      <article class="popup-card">
        <div class="popup-card__topline">
          <span class="map-pass-badge ${this.passBadgeClass(resort.pass_type)}">${this.escape(resort.pass_type)}</span>
          <span>${this.escape(resort.updated_label)}</span>
        </div>
        <h3>${this.escape(resort.name)}</h3>
        <p>${this.escape(resort.location)}</p>
        <div class="popup-weather"><strong>${Math.round(resort.current_temperature)}&deg;F</strong><em>${this.escape(resort.weather_summary)}</em></div>
        <dl class="popup-metrics">
          <div><dt>Base</dt><dd>${resort.snow_depth_inches}&quot;</dd></div>
          <div><dt>24h</dt><dd>${resort.new_snow_24h_inches}&quot;</dd></div>
          <div><dt>7-day snow forecast</dt><dd>${resort.forecast_snow_7d_inches}&quot;</dd></div>
          <div><dt>Score</dt><dd>${this.scoreDisplay(resort)}</dd></div>
        </dl>
        <a class="popup-cta" href="${this.escapeAttribute(resort.detail_url)}" target="_blank" rel="noopener">View resort</a>
      </article>
    `
  }

  selectedCardHtml(resort) {
    return `
      <div class="selected-resort-card__media selected-resort-card__media--${resort.condition_quality}">
        <div>
          <small>Snow Condition Score</small>
          <strong>${this.scoreDisplay(resort)}</strong>
        </div>
        <span>${this.escape(this.conditionLabel(resort))}</span>
      </div>
      <div class="selected-resort-card__body">
        <p class="eyebrow">${this.escape(resort.updated_label)}</p>
        <h2>${this.escape(resort.name)}</h2>
        <p>${this.escape(resort.location)}</p>
        <div class="selected-resort-card__badges">
          ${resort.pass_types.length ? resort.pass_types.map((pass) => `<span class="map-pass-badge ${this.passBadgeClass(pass)}">${this.escape(pass)}</span>`).join("") : `<span class="map-pass-badge map-pass-badge--none">No Pass</span>`}
          <span class="status-pill status-pill--${resort.open_status}">${this.escape(resort.open_status)}</span>
        </div>
        <dl class="selected-resort-card__metrics">
          <div><dt>Current</dt><dd>${Math.round(resort.current_temperature)}&deg;F</dd></div>
          <div><dt>Base depth</dt><dd>${resort.snow_depth_inches}&quot;</dd></div>
          <div><dt>24h snow</dt><dd>${resort.new_snow_24h_inches}&quot;</dd></div>
          <div><dt>7-day snow forecast</dt><dd>${resort.forecast_snow_7d_inches}&quot;</dd></div>
          <div><dt>Wind</dt><dd>${resort.wind_mph} mph</dd></div>
          <div><dt>Precip</dt><dd>${resort.precip_probability}%</dd></div>
        </dl>
        <p class="selected-resort-card__summary">${this.escape(resort.weather_summary)}</p>
        <a class="primary-button" href="${this.escapeAttribute(resort.detail_url)}" target="_blank" rel="noopener">View resort</a>
      </div>
    `
  }

  scoreDisplay(resort) {
    if (resort.conditions_score != null) return Math.round(resort.conditions_score)
    if (resort.open_status === "closed") return "Closed"

    return "No score"
  }

  conditionLabel(resort) {
    if (resort.open_status === "closed") return "Closed"
    if (resort.conditions_score == null) return "No score"

    return resort.condition_label
  }

  updateResultCount(count) {
    this.resultCountTarget.textContent = `${count} ${count === 1 ? "resort" : "resorts"} shown`
  }

  updateInsights(resorts) {
    const visible = resorts.filter((resort) => resort.open_status === "open")
    const candidates = visible.length ? visible : resorts
    const best = this.maxBy(candidates, "conditions_score")
    const snow = this.maxBy(candidates, "forecast_snow_7d_inches")
    const ikon = this.maxBy(candidates.filter((resort) => resort.pass_types.includes("Ikon")), "conditions_score")
    const epic = this.maxBy(candidates.filter((resort) => resort.pass_types.includes("Epic")), "conditions_score")

    this.insightsTarget.querySelector("[data-insight='count']").textContent = resorts.length
    this.insightsTarget.querySelector("[data-insight='best']").textContent = best?.name || "-"
    this.insightsTarget.querySelector("[data-insight='snow']").textContent = snow?.name || "-"
    this.insightsTarget.querySelector("[data-insight='ikon']").textContent = ikon?.name || "-"
    this.insightsTarget.querySelector("[data-insight='epic']").textContent = epic?.name || "-"
  }

  maxBy(resorts, field) {
    return resorts.reduce((winner, resort) => {
      if (!winner) return resort
      return Number(resort[field] || 0) > Number(winner[field] || 0) ? resort : winner
    }, null)
  }

  passBadgeClass(passType) {
    if (/ikon/i.test(passType)) return "map-pass-badge--ikon"
    if (/epic/i.test(passType)) return "map-pass-badge--epic"

    return "map-pass-badge--none"
  }

  escape(value) {
    const element = document.createElement("span")
    element.textContent = value == null ? "" : String(value)
    return element.innerHTML
  }

  escapeAttribute(value) {
    return this.escape(value).replace(/`/g, "&#96;")
  }
}
