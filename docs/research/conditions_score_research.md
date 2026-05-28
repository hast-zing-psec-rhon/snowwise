# Conditions Score Research

## Executive recommendation

Start with a transparent, deterministic `ConditionsScore` that returns a 0-100 score plus a label. Treat the score as a **resort-skiing day quality score**, not an avalanche safety rating and not a full terrain-open forecast.

Recommended first production formula:

```text
If resort is closed / offseason / preseason / summer operations: N/A
If fewer than two usable inputs across snow depth, recent snow, weather: N/A

raw_score =
  35 * base_depth_component +
  25 * recent_snow_component +
  10 * forecast_snow_component +
  15 * temperature_component +
  10 * wind_component +
   5 * data_freshness_component

score = clamp(round(raw_score - rain_penalty - missing_data_penalty), 0, 100)
```

Initial labels:

| Score | Label |
|---:|---|
| 90-100 | Excellent |
| 80-89 | Very Good |
| 65-79 | Good |
| 45-64 | Fair |
| 0-44 | Poor |
| N/A | N/A |

This is deliberately simple enough to implement and test now, while leaving room for resort-specific historical normalization later.

## What public sources support the factors?

### 1. Snow depth / base depth

Base depth matters because it is the coverage floor: thin base exposes rocks, brush, ice, and low-angle terrain limitations even when the weather is pleasant. Resort snow reports commonly publish base depth, recent snowfall, and 7-day snowfall. Palisades Tahoe explains that base depth is the depth of the snowpack at a given elevation, that lower and upper mountain reports can differ materially, and that their public report centers on base depth, overnight snowfall, 24-hour snowfall, and 7-day snowfall. Source: [Palisades Tahoe - How We Report Snow](https://blog.palisadestahoe.com/operations/how-we-report-snow/).

CAIC also emphasizes that total snowpack depth is useful, while noting that a shallow snowpack has different structural implications than a deep snowpack. Source: [CAIC - Weather Stations: Measuring Precipitation](https://avalanche.state.co.us/blog/weather-stations-measuring-precipitation).

### 2. Recent snowfall

Recent snow is the strongest positive same-day signal for skier-perceived surface quality, especially when temperatures remain below freezing. Palisades Tahoe treats overnight, 24-hour, and 7-day snowfall as core report fields. CAIC notes that changes in snow depth over a 24-hour period estimate how much new snow is available and how much snow can be transported by wind. Sources: [Palisades Tahoe - How We Report Snow](https://blog.palisadestahoe.com/operations/how-we-report-snow/), [CAIC - Weather Stations: Measuring Precipitation](https://avalanche.state.co.us/blog/weather-stations-measuring-precipitation).

### 3. Forecast snowfall

Forecast snow should help, but it should be weighted less than observed snow because forecasts are uncertain and because the current app data has precipitation type/probability but no forecast snow amount. NOAA/NOHRSC publishes snowfall analyses and forecasts; OpenSnow and resort reports use mountain-specific forecast context as supporting decision information, but the production score should not over-credit a probability-only signal. Source: [NOHRSC](https://www.nohrsc.noaa.gov/).

### 4. Temperature, warm spring conditions, and freeze/thaw

Temperature affects snow preservation, melt, refreeze, rain/snow line, and skier comfort. Avalanche.org summarizes snow, rain, wind, sunshine, and air temperature as important weather factors that influence snow metamorphism and stability. CAIC identifies wet snow problems during prolonged warming or rain-on-snow events. Sources: [Avalanche.org - Weather](https://avalanche.org/avalanche-encyclopedia/weather/), [CAIC - Avalanche Problems](https://prod.avalanche.state.co.us/forecasts/tutorial/avalanche-problems).

For an inbounds consumer score, the key product insight is: **warm sun is not inherently good ski quality**. Pleasant air temperature can mean heavy, slushy, sticky, or rain-damaged snow, especially at low elevation or with low base depth. The score should therefore penalize high temperatures during winter/spring instead of treating them as comfort-positive.

### 5. Wind

Wind degrades conditions by scouring snow from exposed runs, loading other aspects, creating wind slab/wind crust, increasing wind chill, and sometimes affecting lift operations. CAIC describes wind slab formation from wind-transported snow and also notes that wind loading or scouring can skew sensor readings. Sources: [CAIC - Avalanche Problems](https://prod.avalanche.state.co.us/forecasts/tutorial/avalanche-problems), [Palisades Tahoe - How We Report Snow](https://blog.palisadestahoe.com/operations/how-we-report-snow/).

### 6. Rain

Rain should be a strong penalty. Rain-on-snow introduces liquid water into the snowpack, degrades surface quality, can create wet avalanche problems, and often precedes refrozen crust. CAIC identifies wet slabs as associated with prolonged warming and/or rain-on-snow; CAIC also notes liquid precipitation data is useful for identifying rain-on-snow events. Sources: [CAIC - Avalanche Problems](https://prod.avalanche.state.co.us/forecasts/tutorial/avalanche-problems), [CAIC - Weather Stations: Measuring Precipitation](https://avalanche.state.co.us/blog/weather-stations-measuring-precipitation).

### 7. Data freshness and representativeness

Freshness matters because mountain weather changes rapidly and automated stations have outages. CAIC's weather station help page says station data availability varies by reporting frequency, measured variables, temporary outages, telemetry issues, and maintenance; it also notes not every station records all parameters. CAIC's precipitation article cautions that automated SNOTEL stations can have errors and that data from a single point may not represent an entire area because precipitation varies across elevation bands and aspects. Sources: [CAIC - Weather Station Map Help](https://avalanche.state.co.us/forecasts/help/weather-station-map-help), [CAIC - Weather Stations: Measuring Precipitation](https://avalanche.state.co.us/blog/weather-stations-measuring-precipitation).

## Historical baseline feasibility

### Public historical sources

Credible public sources exist, but resort-specific baselines are uneven:

1. **USDA NRCS SNOTEL / snow course data**: strong for western U.S. mountain regions. Drought.gov summarizes SNOTEL as an automated near-real-time network for mid- to high-elevation mountain hydroclimate data and says standard stations provide snow water equivalent, snow depth, precipitation, and temperature. Period of record listed there is 1980-present. Source: [Drought.gov - NRCS SNOTEL and Snow Course Data](https://www.drought.gov/data-maps-tools/nrcs-snotel-and-snow-course-data).
2. **NOAA NOHRSC National Snow Analyses / SNODAS-style products**: strong gridded U.S. coverage for current and archived snow depth/SWE at about 1 km resolution, useful for regional and elevation-band baselines where resort reports are unavailable. Source: [NOHRSC](https://www.nohrsc.noaa.gov/).
3. **NOAA NCEI U.S. Climate Normals and Snow Climatology**: useful for station monthly normals, snowfall, and snow depth frequencies. NCEI describes climate normals as official 30-year averages and statistics from nearly 15,000 U.S. stations; more than 5,700 precipitation stations have adequate observations for snowfall and snow depth normals. Sources: [NCEI U.S. Climate Normals](https://www.ncei.noaa.gov/products/land-based-station/us-climate-normals), [NCEI United States Snow Climatology](https://www.ncei.noaa.gov/access/metadata/landing-page/bin/iso?id=gov.noaa.ncdc%3AC00000).
4. **NOAA GHCNd**: global daily station data with maximum/minimum temperature, precipitation, snowfall, and snow depth, but station proximity and mountain representativeness vary. Source: [NCEI GHCNd](https://www.ncei.noaa.gov/products/land-based-station/global-historical-climatology-network-daily).
5. **B.C. Snow Survey / Automated Snow Weather Stations**: strong for British Columbia, including snow water equivalent, snow depth, air temperature, and precipitation from mountain stations. Source: [Province of British Columbia - Snow survey data](https://www2.gov.bc.ca/gov/content/environment/air-land-water/water/water-science-data/water-data-tools/snow-survey-data).
6. **ECCC / Canadian historical daily snow depth**: useful for Canada, but resort/mountain station fit must be validated. Source: [ECCC Canadian Historical Daily Snow Depth Database](https://data-donnees.az.ec.gc.ca/data/climate/scientificknowledge/canadian-historical-daily-snow-depth-database?lang=en).

### Resort-specific baselines now?

Resort-specific historical baselines are **not feasible as a first production dependency** without additional station mapping and validation. The reasons:

- Resorts often measure at proprietary or operational snow plots, not public climate stations.
- The app's `ResortLocation` rows include base/summit/weather-station anchors, but not yet a vetted mapping to a long-record SNOTEL, snow course, COOP, ASWS, or GHCNd station.
- Base and upper-mountain depths differ; one public station can misrepresent low-elevation access or high-elevation bowls.
- Snow depth varies by elevation, aspect, wind exposure, canopy, and snowmaking.
- International resorts have heterogeneous public data access and different reporting norms.

**Recommendation:** start with region/month baselines in `data/condition_score_baselines.csv`, use those as conservative expected coverage thresholds, and add resort-specific station baselines later.

## Baseline strategy

The included CSV is a **first-pass heuristic baseline**, not a historical truth table. It should be used only until the app builds a normalized climatology table from vetted stations or gridded data.

Use it as follows:

1. Assign each resort to a coarse `region` using country/state/province and, later, elevation band.
2. Choose the month of `WeatherForecast#forecast_for` or `SnowObservation#observed_at`.
3. Look up:
   - `baseline_base_depth_inches`: minimum expected skiable coverage for the region/month.
   - `good_base_depth_inches`: level at which base depth should no longer materially cap the score.
   - `excellent_base_depth_inches`: level at which coverage is excellent for that region/month.
4. Prefer `upper_depth_inches`, then `mid_depth_inches`, then `base_depth_inches`, but apply low-elevation spring penalties if only upper depth is strong and the resort has a low base elevation.

## Detailed formula

### Operating-status gate

Return N/A if `SnowObservation.operating_status` clearly indicates non-ski operations:

```ruby
CLOSED_STATUSES = %w[closed offseason pre-season preseason summer temporarily_closed]
```

Socratic design question for implementation: do we want “closed due to storm/wind today” to be N/A or Poor? For trip planning, a temporary operational closure should probably be Poor if it is in-season and weather-related, but N/A if it is preseason/offseason.

### Base depth component: 35 points

Use the best available snowpack depth:

```text
depth = upper_depth_inches || mid_depth_inches || base_depth_inches
baseline = monthly regional baseline
ratio = depth / good_base_depth_inches
base_depth_component = clamp(ratio, 0, 1)

If depth >= excellent_base_depth_inches: base_depth_component = 1.0
If depth < baseline_base_depth_inches: base_depth_component *= depth / baseline_base_depth_inches
```

Why nonlinear below baseline? Thin coverage should cap the final result. A 6-inch powder day on a 12-inch base is fun in very limited terrain but should not score like a filled-in midwinter powder day.

Suggested hard caps:

```text
if depth < 8 inches: max_score = 35
if depth < 16 inches: max_score = 55
if month in Mar/Apr/May and depth < baseline: max_score = 60
```

### Recent snow component: 25 points

Observed snow should be weighted over forecast. Use 24h first, then 48h, then 7d as trailing context:

```text
powder_24 = clamp(new_snow_24h_inches / 10.0, 0, 1)
storm_48  = clamp(new_snow_48h_inches / 18.0, 0, 1)
week_7d   = clamp(new_snow_7d_inches / 36.0, 0, 1)

recent_snow_component = 0.60 * powder_24 + 0.25 * storm_48 + 0.15 * week_7d
```

Temperature adjustment:

```text
if weather_forecast.temperature > 34 and weather_forecast.precip_type != "snow": recent_snow_component *= 0.75
if weather_forecast.temperature > 40: recent_snow_component *= 0.50
if weather_forecast.precip_type == "rain": recent_snow_component *= 0.25
```

### Forecast snow component: 10 points

The fields listed for current scoring do not include forecast snowfall amount. If `WeatherForecast#precip_intensity` is populated and unit-normalized, it can later inform rain intensity; for the first score, use a conservative probability/type proxy:

```text
if weather_forecast.precip_type == "snow": forecast_snow_component = weather_forecast.precip_probability || 0
elsif weather_forecast.precip_type in ["sleet", "mixed", "wintry_mix"]: forecast_snow_component = 0.30 * weather_forecast.precip_probability
else: forecast_snow_component = 0
```

Later, add forecast snowfall/liquid equivalent and replace this with:

```text
forecast_snow_component = clamp(forecast_snow_24h_inches / 8.0, 0, 1)
```

### Temperature component: 15 points

Use current temperature when available; otherwise use daily high/low average. Score should prefer below-freezing snow preservation, not beach weather.

```text
temp = weather_forecast.temperature || ((weather_forecast.temperature_high + weather_forecast.temperature_low) / 2)

case temp
when nil       then missing
when -10..28   then 1.00
when 29..32    then 0.95
when 33..36    then 0.80
when 37..40    then 0.55
when 41..45    then 0.30
else                0.10
end
```

Additional spring guardrail:

```text
if month in [3,4,5] && weather_forecast.temperature_high && weather_forecast.temperature_high > 42
  temperature_component = [temperature_component, 0.45].min
end
```

### Wind component: 10 points

Use wind speed in mph:

```text
case weather_forecast.wind_speed
when nil     then missing
when 0...15  then 1.00
when 15...25 then 0.80
when 25...35 then 0.50
when 35...45 then 0.25
else              0.05
end
```

If later wind gusts are added, use gusts for lift-impact risk and sustained speed for surface quality.

### Rain penalty

Rain should be a subtractive penalty because it can overwhelm all positive factors:

```text
rain_penalty = 0
if weather_forecast.precip_type == "rain"
  rain_penalty += 30 * weather_forecast.precip_probability
  rain_penalty += 10 if weather_forecast.temperature && weather_forecast.temperature > 34
  rain_penalty += 10 if weather_forecast.temperature_high && weather_forecast.temperature_high > 40
elsif weather_forecast.precip_type == "mixed" || weather_forecast.precip_type == "sleet"
  rain_penalty += 12 * weather_forecast.precip_probability
end
```

Hard caps:

```text
if weather_forecast.precip_type == "rain" && weather_forecast.precip_probability >= 0.60
  max_score = [max_score, 45].min
end
if weather_forecast.precip_type == "rain" && weather_forecast.temperature && weather_forecast.temperature > 38
  max_score = [max_score, 40].min
end
```

### Data freshness component: 5 points

Use `SnowObservation#observed_at`, falling back to `SnowObservation#queried_at`.

```text
age_hours = now - (snow_observation.observed_at || snow_observation.queried_at)
case age_hours
when 0..12   then 1.00
when 12..24  then 0.80
when 24..48  then 0.50
when 48..72  then 0.25
else              0.00
end
```

If the snow observation's `confidence` is present, multiply snow-dependent components by confidence, bounded to `[0.25, 1.0]` so low confidence penalizes but does not obliterate otherwise useful weather data.

### Missing data penalty

The score should degrade gracefully but remain explainable.

Required minimum to score:

- at least one snow signal: any base/mid/upper depth or any recent snow field; and
- at least one weather signal: temperature, wind, or precipitation type/probability.

Missing penalties:

```text
missing_data_penalty = 0
missing_data_penalty += 12 if no snow depth at any elevation
missing_data_penalty += 6  if no recent snow fields
missing_data_penalty += 6  if no temperature
missing_data_penalty += 4  if no wind
missing_data_penalty += 4  if no precipitation type/probability
missing_data_penalty += 6  if snow observation older than 72 hours
```

Also cap by completeness:

```text
if no snow depth at any elevation: max_score = [max_score, 75].min
if no weather data at all: N/A
if no snow observation at all: max_score = [max_score, 65].min
```

This handles the product trade-off: users get a useful ranking when partial data exists, but missing snow depth cannot produce an “Excellent” score.

## Rails implementation approach

Do not add migrations yet. Implement later as a service object and tests:

```text
app/services/conditions_score_calculator.rb
spec/services/conditions_score_calculator_spec.rb
```

Suggested API:

```ruby
ConditionsScoreCalculator.call(
  resort: resort,
  snow_observation: latest_snow_observation,
  weather_forecast: weather_forecast,
  baseline: baseline_row,
  as_of: Time.current
)
# => ConditionsScoreResult(score: 84, label: "Very Good", reasons: [...], data_quality: ...)
```

Implementation details:

- Keep the formula deterministic and pure; avoid database queries inside the calculator.
- Return reason codes such as `:fresh_powder`, `:thin_base`, `:rain_penalty`, `:stale_snow_observation`, `:high_wind`.
- Store constants in the service initially; move to YAML or database only after product tuning proves the need.
- Load `data/condition_score_baselines.csv` through a small lookup class or seed task later.
- Test boundary values: exactly 32°F, 33°F, no depth, stale data, closed status, rain probability caps.

Guiding design question: should users see the raw formula or a plain-English explanation? For trust, show the label and two or three reasons rather than only a number.

## Fields to add later

Recommended additions, in priority order:

1. `WeatherForecast#forecast_snow_24h_inches` and `forecast_snow_72h_inches` or liquid equivalent plus snow/rain line. This materially improves the forecast component.
2. `WeatherForecast#wind_gust_mph`. Sustained wind and gusts have different operational meanings.
3. `Resort#climate_region` or `ResortLocation#climate_region`. Needed for region/month baseline lookup.
4. `ResortLocation#elevation_band` (`base`, `mid`, `upper`, `summit`) already partly exists via `location_type`; score logic should explicitly prefer mid/upper winter observations and base-area spring risk.
5. `HistoricalSnowBaseline` table with columns like `resort_location_id`, `month`, `day_of_year`, `median_depth_inches`, `p25_depth_inches`, `p75_depth_inches`, `source`, `period_start_year`, `period_end_year`.
6. `surface_condition` normalized enum if public resort reports can be parsed reliably: powder, packed_powder, machine_groomed, granular, spring, icy, wet, variable.
7. `terrain_open_percent` and `lift_open_percent`. Base depth is a proxy; open terrain is the user-facing reality.
8. `snowmaking_coverage_percent`, eventually, because Midwest/East resorts can be skiable with lower natural snow depth.

## Example outcomes

### High-quality powder day

Inputs:

- Operating status: open
- Upper depth: 72 in
- New snow: 14 in / 24h, 20 in / 48h, 36 in / 7d
- Temperature: 24°F
- Wind: 12 mph
- Precipitation: snow, probability 0.40
- Observation age: 4 hours

Expected: **Excellent, 94-100**. Strong depth, strong observed snow, cold preservation, low wind, fresh observation.

### Warm spring day with low base

Inputs:

- Operating status: open
- Base depth: 14 in; upper depth missing
- New snow: 0 in / 24h, 2 in / 7d
- Temperature: 48°F high, 39°F current
- Wind: 8 mph
- Precipitation: none
- Month: April

Expected: **Poor to Fair, 35-50**. Pleasant weather is not enough; low base and warm temperatures cap the score.

### Closed resort

Inputs:

- Operating status: closed/offseason/preseason/summer

Expected: **N/A**. Do not score non-ski operations.

### Missing snow depth but valid weather

Inputs:

- Operating status: open
- Snow depth: missing
- New snow: 6 in / 24h, 8 in / 48h
- Temperature: 27°F
- Wind: 10 mph
- Precipitation: snow, probability 0.30
- Observation age: 8 hours

Expected: **Good, capped near 75**. Recent snow and cold weather are positive, but missing depth prevents a high-confidence Excellent score.

### Strong wind/rain day

Inputs:

- Operating status: open
- Upper depth: 70 in
- New snow: 4 in / 24h, 18 in / 7d
- Temperature: 38°F current, 44°F high
- Wind: 42 mph
- Precipitation: rain, probability 0.80
- Observation age: 5 hours

Expected: **Poor, capped near 40-45**. Deep base cannot overcome rain, warm temperature, and strong wind.

## Known limitations and counterarguments

- **Avalanche safety:** This is not an avalanche forecast. Inbounds conditions and avalanche risk differ, and avalanche centers should remain the authority for backcountry decisions.
- **Snowmaking:** Eastern and Midwest resorts can ski well with lower natural base if they have snowmaking and grooming. The first score will understate some machine-made/groomed quality until terrain open and snowmaking fields exist.
- **Surface condition:** Powder, packed powder, corduroy, granular, ice, and slush are user-visible quality states not inferable from current fields with high precision.
- **Aspect/elevation:** One resort-level score can hide lower-mountain rain and upper-mountain snow. Later UI should display base/mid/upper condition indicators.
- **Historical baseline uncertainty:** Regional baselines are coarse. They are better than no seasonality guardrail but should be replaced by station/gridded climatologies.
- **Forecast uncertainty:** Probability-only forecast precipitation should not dominate the score. Observed snow should remain primary.
