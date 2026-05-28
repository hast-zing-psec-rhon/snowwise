# Snow Report JSON / Widget Endpoint Investigation

Research date: 2026-05-26 UTC

## Executive conclusion

There is no single unauthenticated official JSON endpoint that covers all resorts in this repo. There **are** useful public widget endpoints for a few resort families, and there are licensed multi-resort APIs that appear to solve the problem more cleanly.

Recommended production hierarchy:

1. **Licensed structured feed**: Mountain News / OnTheSnow Partner API or SnoCountry.
2. **Official public widget JSON where available**: Palisades Tahoe `mtnpowder`, Aspen Snowmass `WeatherDashboard/Feed`, etc.
3. **Official HTML/PDF extraction**: Summit at Snoqualmie Next.js/RSC HTML, Hakuba Valley static HTML, Whistler Blackcomb official PDF report.
4. **Aggregator fallback** only when official data is unavailable and clearly marked.
5. **Model-only snow depth** should be labeled as model-derived, not resort-reported base depth.

A machine-readable candidate list was added at `data/snow_endpoint_candidates.csv`.

## Endpoint candidates tested

### Palisades Tahoe / Alpine Meadows

Official page:

- `https://www.palisadestahoe.com/mountain-information/snow-weather`

The page loads a Vue widget from Netlify:

- `https://squaw-mtn-status-weather-new.netlify.app/squaw/js/app.js`

The widget JS constructs requests to:

- `https://mtnpowder.com/feed?resortId=61`
- `https://mtnpowder.com/feed?resortId=62`
- `https://mtnpowder.com/feed/61/weather`
- `https://mtnpowder.com/feed/62/weather`

Findings:

- `resortId=61` returned public JSON for Palisades Tahoe.
- The `SnowReport` object includes `BaseConditions`, `StormTotalIn`, `SnowBaseRangeIn`, `SeasonTotalIn`, and nested `BaseArea`, `MidMountainArea`, and `SummitArea` objects.
- `BaseArea` included fields such as `BaseIn`, `BaseCm`, `Last24HoursIn`, `Last48HoursIn`, `Last72HoursIn`, and `Last7DaysIn`.
- The weather endpoints returned public JSON with base/mid/summit `CurrentConditions`.
- `resortId=62` currently returned forecast-style JSON but no `SnowReport` object in this pass; Alpine may need a different or seasonal feed for depth data.

Implementation view: this is directly ingestible in Rails via `Net::HTTP`/Faraday, with a provider adapter mapping `BaseArea.BaseIn`, `MidMountainArea.BaseIn`, and `SummitArea.BaseIn` into `snow_observations`.

### Aspen Snowmass

Official page:

- `https://www.aspensnowmass.com/our-mountains/snow-report`

The page contains a header weather widget with:

- `data-endpoint=/AspenSnowmass/WeatherDashboard/Feed`

Tested endpoint:

- `https://www.aspensnowmass.com/AspenSnowmass/WeatherDashboard/Feed`

Findings:

- Endpoint returned public JSON.
- Current response included `season`, `mountains`, `weather`, `forecast`, and temperature fields.
- Because the current response is summer-season, `weather.snow` was `null` in the sample.
- The endpoint is still the best official candidate for Aspen Mountain, Aspen Highlands, Buttermilk, and Snowmass; retest during winter to confirm snow-field names.

Implementation view: add an Aspen adapter that polls this endpoint and ignores rows where `weather.snow` is null.

### Summit at Snoqualmie / Alpental

Official page:

- `https://www.summitatsnoqualmie.com/alpental/mountain-report`

Findings:

- The page is a Next.js App Router / React Server Components page.
- It does **not** expose a simple `__NEXT_DATA__` JSON block.
- It embeds `self.__next_f.push(...)` RSC flight payloads in HTML.
- The payload includes weather station metadata and snow-condition component configuration, including `filteredLocationList` values such as `Alpental`, `Alpental Mid`, and `Alpental Top`, plus `snowfallStatsList` values such as `snowSince5am`, `snow12Hours`, `snow24Hours`, `snow48Hours`, `snowSeasonTotal`, and `base`.
- The rendered/search-captured page exposed base-depth values for Alpental during prior source research, but this investigation did not find a clean backend JSON URL.

Implementation view: either parse the official page HTML/RSC payload or keep it as a fallback source until the backing API is identified. Because it is official and server-rendered, HTML extraction is defensible with conservative validation.

### Hakuba Valley

Official page:

- `https://www.hakubavalley.com/en/weather_en/`

Findings:

- The page is static WordPress-style HTML with `report-list` and `report-item` blocks.
- It includes component resort detail URLs such as `detail_goryu_en`, `detail_happo_en`, `detail_iwatake_en`, etc.
- It contains weather and snow report data in the HTML, not a clean JSON API.
- The page references `//var.resortech.jp/aria/vo.hakubavalley.com.js`; direct DNS fetch failed during this investigation, so no stable resortech JSON endpoint was confirmed.

Implementation view: HTML extraction is viable and should be easier than browser automation. Parse each `.report-item` and resort detail page; preserve update time and cm-to-in conversion.

### Whistler Blackcomb

Official candidates:

- `https://www.whistlerblackcomb.com/mountain-info/snow-report`
- `https://secure.whistlerblackcomb.com/TomPDF/Default.aspx?Season=1&Type=bg`

Findings:

- The public snow-report page did not expose usable JSON in static fetches.
- The `TomPDF` endpoint returned `application/pdf` and appears to be an official report PDF endpoint.
- Search results exposed `SNOW BASE` labels from that PDF endpoint, but direct fetch requires PDF text extraction.

Implementation view: treat Whistler/Blackcomb as PDF extraction unless a cleaner endpoint is found. Use a PDF text extractor in a background job, then parse `SNOW BASE` and related lines conservatively.

### Vail Resorts / Epic family pages

Official example:

- `https://www.vail.com/the-mountain/mountain-conditions/snow-and-weather-report.aspx`

Findings:

- Static fetches were blocked or returned short challenge/reservation shell pages for some Vail Resorts domains.
- No public JSON endpoint was confirmed in this pass.
- The `.aspx` pages likely hydrate through protected scripts or app-specific services; discovery may require a real browser session and possibly dealing with bot-protection controls.

Implementation view: do **not** build the app around scraping these pages. Prefer a licensed source for Epic/Vail properties. If scraping is still desired, implement it as a separate, rate-limited, compliance-reviewed research task.

### Licensed multi-resort APIs

#### Mountain News / OnTheSnow Partner API

Official docs indicate:

- Batch endpoint: `https://partner-api.onthesnow.com/resorts/snowreport`
- Per-resort endpoint: `https://partner-api.onthesnow.com/resort/{resortId}/snowreport`

The docs state the API returns:

- base/mid/summit snow depths where available,
- recent snowfall including 7-day data,
- surface type,
- lift and terrain status,
- resort operating status,
- update timestamps.

This is the cleanest product fit if licensing is feasible.

#### SnoCountry Conditions Feed

Candidate endpoint:

- `https://feeds.snocountry.net/getSnowReport.php`

SnoCountry docs indicate JSON snow-report feeds are available with an API key and resort IDs.

## Rails implementation recommendation

Create provider adapters rather than one generic scraper:

```ruby
SnowReports::Providers::MountainNewsClient
SnowReports::Providers::SnoCountryClient
SnowReports::Providers::PalisadesMtnPowderClient
SnowReports::Providers::AspenSnowmassWeatherDashboardClient
SnowReports::Providers::HakubaHtmlClient
SnowReports::Providers::WhistlerPdfClient
```

Each adapter should return a normalized object:

```ruby
SnowReportResult = Data.define(
  :resort_name,
  :resort_location_name,
  :observed_at,
  :base_depth_inches,
  :mid_depth_inches,
  :upper_depth_inches,
  :new_snow_24h_inches,
  :new_snow_48h_inches,
  :new_snow_7d_inches,
  :surface_condition,
  :source_name,
  :source_url,
  :raw_payload,
  :confidence,
  :notes
)
```

Practical safeguards:

- Run in background jobs, not web requests.
- Store raw payloads for audit/reparse.
- Reject stale updates unless explicitly marked as stale/off-season.
- Use per-provider rate limits.
- Keep official and model-derived values separate.
- Treat zero snow as valid when the source explicitly reports zero/no snow, closed, pre-season, off-season, or summer operations. Do not infer zero from a missing field alone.

## OpenAI API role

Use OpenAI extraction only as a fallback parser for official HTML/PDF pages that have visible values but no clean JSON endpoint. For this app's daily/weekly cadence, the practical approach is: Rails fetches source pages, stores the source text/raw payload, and calls the OpenAI API only to normalize unstructured official report text into a constrained schema.

Recommended flow:

1. Fetch official page/PDF yourself in Rails from the source URL attached to the resort/provider.
2. Extract machine text deterministically first; trim navigation, ads, and unrelated forecast text before the model call.
3. Send only the relevant extracted text to OpenAI with a strict JSON schema.
4. Require `null` for missing numeric values.
5. Permit `0` for base depth only if the source explicitly reports zero/no snow or supports closed/pre-season/off-season/summer operations. The returned row should include a `zero_depth_reason` such as `explicit_zero`, `closed`, `preseason`, `offseason`, or `no_snow`.
6. Preserve explicit source values even when a resort is closed. Example: Sunday River's official current report exposed 20 in snow depth with 0 trails open; store 20 and mark operating status closed rather than forcing 0.
7. Validate numeric fields, timestamp freshness, source URL, unit conversion, and status before storing.
8. Store the raw extracted text/payload hash for audit and reprocessing.

Suggested model output contract:

```json
{
  "resort_name": "string",
  "observed_at": "ISO-8601 timestamp or null",
  "base_depth_inches": "number or null",
  "mid_depth_inches": "number or null",
  "upper_depth_inches": "number or null",
  "new_snow_24h_inches": "number or null",
  "new_snow_48h_inches": "number or null",
  "new_snow_7d_inches": "number or null",
  "operating_status": "open|closed|preseason|offseason|unknown",
  "zero_depth_reason": "explicit_zero|closed|preseason|offseason|no_snow|null",
  "source_evidence": "short quote/paraphrase of the supporting text",
  "confidence": "high|medium|low"
}
```

Do not ask OpenAI to browse independently as the primary production mechanism; that makes provenance, caching, rate limits, and reproducibility harder. The app should own fetching, caching, provenance, and retry policy, while OpenAI performs bounded extraction from source text the app already retrieved.
