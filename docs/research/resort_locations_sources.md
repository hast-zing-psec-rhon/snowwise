# Resort Locations Sources

Research date: 2026-05-25

## Purpose

This document supports `data/resort_locations.csv`, a seed-data file intended for a future `resort_locations` table. The goal is to let weather, snow, and forecast records attach to specific coordinates rather than directly to broad resort rows.

No database migrations or database writes were made for this research pass.

## CSV Created

`data/resort_locations.csv`

Schema:

```text
resort_name,name,location_type,latitude,longitude,elevation_feet,is_primary,notes,source_url
```

## Methodology

This was a first-pass full-coverage location dataset for every resort currently listed in `data/resorts.csv`.

Method:

1. Read all resort names from `data/resorts.csv`.
2. Created at least one `resort_locations` row for every resort.
3. Used the existing resort latitude/longitude from `data/resorts.csv` when present. Those coordinates were previously gathered from official pass/resort CMS records, official resort pages, official resort websites, or reliable map/geocoding references during the pass-access seed-data work.
4. For resorts that had no latitude/longitude in `data/resorts.csv`, added an approximate `forecast_point` coordinate from OpenStreetMap/Nominatim-style map/geocoding references or closely related official resort-domain geography.
5. Marked exactly one row per resort as `is_primary=true`.
6. Preferred a base-area or general forecast point for the first primary row because the immediate use case is weather forecasting, not summit snowpack modeling.
7. Left `elevation_feet` blank unless a clearly source-checked elevation was already available. This avoids inventing elevation precision.

## Primary Location Policy

Each resort currently has exactly one primary row:

- `location_type=base` where the inherited coordinate is treated as the resort/base forecast point.
- `location_type=forecast_point` where the coordinate was explicitly backfilled because `data/resorts.csv` had no coordinate.

This is intentionally conservative. The primary point is good enough to bootstrap forecast-provider lookup, but it should not be treated as a canonical weather station or snow stake unless later rows explicitly identify that source.

## Sources Used

Primary source families:

- Existing `data/resorts.csv` resort coordinates and website URLs.
- Official Ikon/Epic resort and destination pages documented in `docs/research/pass_access_sources.md`.
- Official resort websites listed in `data/resorts.csv`.
- OpenStreetMap search/map references for resorts that had missing coordinates in `data/resorts.csv`.

The OpenStreetMap search references are stored directly in `source_url` for the backfilled rows. Rows derived from existing resort coordinates use the resort's website URL as the source URL and explain in `notes` that the coordinate came from the existing resort seed-data coordinate.

## Backfilled Coordinate Rows

The following resorts lacked latitude/longitude in `data/resorts.csv` and received approximate first-pass forecast points in `data/resort_locations.csv`:

- Cervino Ski Paradise
- Courmayeur Mont Blanc
- Giant Ski Area
- Hasuike Ski Area
- Higashidateyama Ski Area
- Hoppo Bunadaira Ski Area
- Ichinose Yamanokami Ski Area
- Kumanoyu Ski Area
- La Thuile - Espace San Bernardo
- Maruike Ski Area
- Monterosa Ski
- Nishidateyama Ski Area
- Pila
- Shibutoge Ski Area
- Takamagahara Mammoth Ski Area
- Tannenomori Okojo Ski Area
- Yakebitaiyama Ski Area
- Yokoteyama Ski Area

Most of these are member ski areas in large grouped destinations such as Shiga Kogen Mountain Resort or Valle d'Aosta. Their coordinates should be revisited with official trail maps, official resort GIS, or official snow/weather pages before high-confidence production weather modeling.

## Caveats About Approximate Coordinates

A single coordinate is a simplification for ski-area weather.

Important limitations:

1. **Vertical gradient:** Temperature, wind, precipitation type, and snowfall can vary dramatically between base, mid-mountain, and summit.
2. **Aspect and exposure:** Two lift pods at the same resort can have different wind loading and snow preservation.
3. **Large resort groups:** Some pass destinations include many physical ski areas spread across valleys or countries. A single group coordinate would be misleading, so this dataset attaches rows only to physical resort rows from `data/resorts.csv`.
4. **Map/geocoding precision:** Some backfilled coordinates are approximate map points, not official snow stakes or weather stations.
5. **Provider grid mismatch:** Weather APIs may resolve a coordinate to a grid cell or station that does not perfectly represent ski terrain.

## Recommended Future Enhancements

For production-quality snow-condition modeling, add additional rows where official data is available:

- `base` — village/base area or main lodge.
- `mid_mountain` — mid-mountain weather forecast point.
- `summit` — upper-mountain forecast point.
- `snow_stake` — official snow stake camera/sensor location.
- `weather_station` — official resort, government, or avalanche-center station.
- `forecast_point` — provider-specific point used for Pirate Weather or another forecast provider.

## Resorts Needing Better Official Weather/Snow-Stake Data Later

Prioritize richer location research for:

- Large western North American resorts: Vail, Whistler Blackcomb member mountains, Park City Mountain, Palisades Tahoe, Mammoth Mountain, Big Sky Resort, Jackson Hole Mountain Resort, Steamboat, Deer Valley Resort, Aspen Snowmass members.
- Multi-base or multi-mountain groups: Aspen Snowmass, Palisades Tahoe, Big Bear Mountain Resort, Killington - Pico, SkiBig3, Niseko United, Hakuba Valley, Resorts of the Canadian Rockies, Les 3 Vallées, Dolomiti Superski, Skirama Dolomiti, Shiga Kogen Mountain Resort, Valle d'Aosta.
- International grouped destinations with approximate member coordinates: Shiga Kogen member areas, Valle d'Aosta member areas, Zillertal, Saalbach & Zell am See-Kaprun, Ski Arlberg, Verbier 4 Vallées.

## Validation Performed

The generated CSV was validated for these invariants:

- Every resort in `data/resorts.csv` has at least one row in `data/resort_locations.csv`.
- Every resort has exactly one `is_primary=true` row.
- Every `resort_name` in `data/resort_locations.csv` exactly matches a resort from `data/resorts.csv`.
- Every row has latitude and longitude.
- Latitude and longitude parse as decimal values.
- `is_primary` is either `true` or `false`.
- `location_type` is one of the allowed values.
- `elevation_feet`, when present, is an integer. It is currently blank for first-pass rows unless later source-checking adds elevations.
- Every row has a `source_url`.

## Unresolved Questions

1. Should the app store forecast-provider metadata, such as Pirate Weather grid cell, station ID, or last geocoding response, in `resort_locations` or a separate provider-specific table?
2. Should `is_primary` mean primary forecast point, primary UI display point, or canonical resort base point? Those may diverge.
3. Should grouped destinations get their own non-weather centroid locations for map display, separate from physical resort weather points?
4. Should elevation be stored in feet only, meters only, or both with unit metadata? The proposed CSV uses feet, but many official international sources publish meters.
5. Should coordinates eventually be provenance-scored, for example `official_station`, `official_resort_page`, `pass_cms`, `government_map`, `openstreetmap`, or `manual_approximation`?

## Elevation Enrichment Pass — 2026-05-25

After the initial coordinate-only pass, an elevation enrichment pass began because elevation is material for snow/rain-line modeling, temperature lapse-rate adjustment, and interpretation of reported snowpack.

### Why Elevation Is Now Being Added

Weather at ski areas is not adequately represented by latitude/longitude alone. For the same resort, base, mid-mountain, summit, and official snow-stake locations can differ materially in:

- temperature,
- precipitation phase,
- wind exposure,
- storm accumulation,
- settled base depth,
- snow preservation,
- and forecast-provider grid-cell relevance.

### Resorts Enriched In This Pass

The first elevation/station enrichment pass focused on the major first-batch resorts and the most accessible official station/stat sources:

- Mammoth Mountain
- Vail
- Breckenridge
- Park City Mountain
- Palisades Tahoe
- Alpine Meadows
- Deer Valley Resort
- Steamboat
- Jackson Hole Mountain Resort
- Big Sky Resort
- Aspen Mountain
- Aspen Highlands
- Buttermilk
- Snowmass

### Official Elevation / Station Sources Added

- Mammoth Mountain fact sheet: https://www.mammothmountain.com/-/media/project/mammoth/library/pdfs/Fact-Sheets/25-26_Marketing_MMSA_Fact-Sheets_85x11
  - Base: 7,953 ft
  - Summit: 11,053 ft

- Vail Resorts help article: https://vail.zendesk.com/hc/en-us/articles/4412287112859-What-is-the-base-elevation-in-Vail
  - Base: 8,200 ft
  - Summit: 11,570 ft

- Breckenridge mountain information: https://www.breckenridge.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 9,600 ft
  - Peak elevation: 12,998 ft

- Park City Mountain information: https://www.parkcitymountain.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 6,800 ft
  - Summit: 10,026 ft

- Palisades Tahoe snow-reporting methodology: https://blog.palisadestahoe.com/operations/how-we-report-snow/
  - Palisades lower snow plot / Patrol Shack: 6,200 ft
  - Palisades Belmont sensor: 8,000 ft
  - Palisades top of Siberia sensor: 8,700 ft
  - Alpine Meadows bottom/top of Roundhouse: 6,950 ft / 7,880 ft
  - Alpine Meadows bottom/top of Scott: 7,075 ft / 8,120 ft
  - Alpine Meadows top of Summit: 8,643 ft

- Deer Valley explore-the-mountain page: https://www.deervalley.com/explore-the-mountain
  - Base: 6,530 ft
  - Summit: 9,570 ft

- Steamboat mountain stats: https://www.steamboat.com/the-mountain/mountain-stats.aspx
  - Base: 6,900 ft
  - Christie Peak: 8,020 ft
  - Mid-Mountain: 9,080 ft
  - Summit / Mt. Werner: 10,568 ft

- Jackson Hole mountain stats: https://www.jacksonhole.com/mountain-stats
  - Base: 6,311 ft
  - Summit: 10,450 ft

- Big Sky snow-report FAQ: https://www.bigskyresort.com/current-conditions/snow-report-faqs
  - Officially lists the Lobo, Lookout Ridge, Andesite, Bavaria, and Liberty Bowl weather stations and identifies Lobo, Lookout Ridge, Bavaria, and Liberty Bowl as ski-patrol-managed. The FAQ does not publish elevations for these stations.

- Big Sky mountain information: https://www.bigskyresort.com/mountain-info
  - Used for first-pass Big Sky base/summit elevation rows. Exact station elevations still need official or avalanche-center confirmation.

- Aspen Snowmass mountain-stats PDF: https://www.aspensnowmass.com/-/media/aspen-snowmass/documents/pdfs/25-26/aspen-snowmass-mountain-stats.pdf
  - Aspen Mountain base/summit: 7,945 ft / 11,262 ft
  - Aspen Highlands base/summit: 8,040 ft / 12,392 ft
  - Buttermilk base/summit: 7,870 ft / 9,900 ft
  - Snowmass base/summit: 8,110 ft / 12,510 ft

### Elevation Data Caveats From This Pass

1. Some official sources publish elevations but not exact station coordinates. In those cases, the CSV uses approximate map/geocoding coordinates and states that limitation in `notes`.
2. Big Sky official resort content identifies weather-station names, but readily accessible official pages did not publish station elevations. Those station rows now use DEM-derived fallback elevations at approximate row coordinates and remain flagged for future replacement with official Big Sky, GNFAC, or other station-feed elevations.
3. Summit rows are useful for lapse-rate and snow-line modeling but should not be assumed to represent official snow stakes unless the source says so.
4. For Palisades Tahoe and Alpine Meadows, the source is stronger than generic mountain stats because it describes actual snow plots/sensors and elevations.
5. The official-source passes enriched selected major resort rows with resort-published elevation values. A later DEM fallback pass filled the remaining blank `elevation_feet` values, but those fallback elevations are lower-confidence than official station/base/summit values.

### Next Elevation Research Priorities

Continue with:

1. Remaining North American Ikon/Epic resorts with official snow reports and published base/summit stats.
2. Vail Resorts properties that share similarly structured `/the-mountain/about-the-mountain/mountain-info.aspx` pages.
3. Resorts with official snow-stake methodology pages, because those are more valuable than generic summit/base statistics.
4. International grouped destinations where base/summit elevation may be published in meters and must be converted cleanly to integer feet.

### DEM Fallback Elevation Pass

After official-source enrichment, remaining blank `elevation_feet` values were filled from the Open-Meteo Elevation API:

- Open-Meteo Elevation API: https://open-meteo.com/en/docs/elevation-api

This API returns DEM-derived elevation in meters for a supplied latitude/longitude. Values were converted to integer feet using `meters * 3.28084` and rounded to the nearest foot. For these fallback rows, `source_url` is the row-specific Open-Meteo API query. The row `notes` preserve the original resort/location source URL and explicitly state that the elevation is DEM-derived, not an official resort-reported weather-station or snow-stake elevation.

The DEM fallback is useful for lapse-rate and forecast-point bootstrapping, but it is not a replacement for official resort station metadata. It should be superseded when official base, mid-mountain, summit, snow-stake, or weather-station elevations are source-checked.


### Additional Vail Resorts / Epic Elevation Sources Added

A follow-up pass added elevations for several Epic/Vail Resorts destinations whose official pages expose mountain-stat elevations:

- Beaver Creek mountain information: https://www.beavercreek.com/The%20Mountain/About%20the%20Mountain/Mountain%20Info.aspx
  - Base: 8,100 ft
  - Highest elevation: 11,440 ft

- Northstar California mountain information: https://www.northstarcalifornia.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 6,330 ft
  - Highest elevation: 8,610 ft

- Heavenly/Vail Resorts help article: https://skiheavenly.zendesk.com/hc/en-us/articles/4412301889435-What-Is-The-Base-Town-Elevation
  - Base: 6,540 ft
  - Summit: 10,067 ft

- Kirkwood official travel-guide page: https://www.kirkwood.com/travel-guide/kirkwood-good-place-to-ski.aspx
  - Base: 7,800 ft
  - Top elevation: 9,800 ft

- Keystone official trail-map PDF: https://www.keystoneresort.com/-/media/keystone/files/kys-trail-map-2021-compressed-final.ashx
  - Base: 9,280 ft
  - Summit: 12,408 ft

- Crested Butte / Vail Resorts newsroom press kit: https://news.vailresorts.com/press-kit?item=30059
  - Base: 9,375 ft
  - Summit: 12,162 ft

- Stowe mountain information: https://www.stowe.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Summit elevation: 4,395 ft
  - Highest skiing elevation: 3,625 ft
  - Base elevation still needs a clearly source-checked official value before filling the primary base row.

These rows continue the same rule: elevation comes from the official resort/source page; coordinates for non-primary summit/highest-elevation rows are approximate unless the official source publishes station coordinates.


### Final Elevation Coverage After This Pass

All current `data/resort_locations.csv` rows now have nonblank integer `elevation_feet` values. Official resort/station elevations are preserved where source-checked; remaining rows use DEM-derived Open-Meteo fallback elevations and are labeled accordingly in notes.

### Additional Official Vail Resorts Mountain-Info Batch

A further official-source pass added base and summit/highest-elevation rows for additional Epic/Vail Resorts destinations. These are mountain-stat elevations rather than necessarily exact weather-station or snow-stake elevations; non-primary summit coordinates remain approximate unless a later official station coordinate is found.

Official sources used:

- Okemo / Vail Resorts tip sheet: https://news.vailresorts.com/okemo-mountain-tip-sheet
  - Base: 1,144 ft; summit: 3,344 ft
- Mount Snow mountain information: https://www.mountsnow.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 1,900 ft; highest elevation: 3,600 ft
- Hunter Mountain mountain information: https://www.huntermtn.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 1,600 ft; highest elevation: 3,200 ft
- Mount Sunapee mountain information: https://www.mountsunapee.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 1,233 ft; highest elevation: 2,743 ft
- Liberty Mountain mountain information: https://www.libertymountainresort.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 570 ft; highest elevation: 1,190 ft
- Seven Springs mountain information: https://www.7springs.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 2,240 ft; highest elevation: 2,994 ft
- Hidden Valley PA mountain information: https://www.hiddenvalleyresort.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 2,405 ft; highest elevation: 2,875 ft
- Laurel Mountain mountain information: https://www.laurelmountainski.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 2,005 ft; highest elevation: 2,766 ft
- Crotched Mountain mountain information: https://www.crotchedmtn.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 1,050 ft; highest elevation: 2,066 ft
- Whitetail mountain information: https://www.skiwhitetail.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 865 ft; highest elevation: 1,800 ft
- Roundtop mountain information: https://www.skiroundtop.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 735 ft; highest elevation: 1,335 ft
- Jack Frost Big Boulder mountain information: https://www.jfbb.com/the-mountain/about-the-mountain/mountain-info.aspx?id=5996
  - Jack Frost base/highest: 1,400 ft / 2,000 ft
  - Big Boulder base/highest: 1,700 ft / 2,175 ft
- Attitash mountain information: https://www.attitash.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 600 ft; highest elevation: 2,350 ft
- Wildcat mountain information: https://www.skiwildcat.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 1,950 ft; highest elevation: 4,062 ft

This batch increased the count of official base+summit/highest-elevation resort profiles but still does not complete the full station-spectrum objective for all 215 resorts. Many resorts still have only a primary base/forecast point with DEM fallback elevation and need official snow-report station research.

### Additional Official Midwest Epic/Vail Mountain-Info Batch

Another pass targeted remaining single-location Epic Midwest resorts whose official Vail Resorts pages expose mountain-stat elevations. These pages generally provide base/highest-elevation facts rather than named weather stations or snow stakes. Therefore the added summit/highest rows should be treated as elevation anchors for forecast modeling, not as exact sensor locations. Non-primary high-elevation coordinates reuse the resort forecast-point coordinates until official station coordinates or georeferenced trail-map points are found.

Official sources used:

- Afton Alps mountain information: https://www.aftonalps.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 350 ft; highest elevation: 700 ft
- Alpine Valley Ohio mountain information: https://www.alpinevalleyohio.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 1,260 ft; highest elevation: 1,500 ft
- Mad River Mountain mountain information: https://www.skimadriver.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Highest elevation: 1,460 ft; longest vertical drop: 300 ft; base entered as approximately 1,160 ft by arithmetic inference because the official page did not expose an explicit base-elevation field in the captured source text.
- Hidden Valley Missouri mountain information: https://www.hiddenvalleyski.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Highest elevation: 860 ft; longest vertical drop: 320 ft; base entered as approximately 540 ft by arithmetic inference because the official page did not expose an explicit base-elevation field in the captured source text.
- Snow Creek mountain information: https://www.skisnowcreek.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 800 ft; highest elevation: 1,100 ft
- Paoli Peaks mountain information: https://www.paolipeaks.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 600 ft; highest elevation: 900 ft
- Mt Brighton mountain information: https://www.mtbrighton.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 1,100 ft; highest elevation: 1,330 ft
- Wilmot mountain information: https://www.wilmotmountain.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Base: 770 ft; highest elevation: 960 ft
- Boston Mills Brandywine combined mountain information: https://www.bmbw.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Combined highest elevation: 871 ft; longest vertical drop: 264 ft. Because the official page is for the combined Boston Mills/Brandywine destination and does not identify per-area base elevations or which physical hill contains the high point, rows added for Boston Mills and Brandywine are explicitly labeled as combined-destination high-elevation references rather than precise physical-resort station records.

Caveat: these additions improve official elevation coverage but still do not complete the full station-spectrum objective. Many remaining resorts still need official snow-report/weather-station research for named base, mid-mountain, summit, snow-stake, or sensor locations.

### Additional Official Boyne / Ikon Mountain-Info Batch

This pass targeted Boyne-operated or Boyne-affiliated Ikon destinations where official resort pages expose elevation anchors. As with the Epic Midwest batch, these are mountain-stat elevations unless the notes say otherwise; they improve forecast-elevation coverage but are not necessarily exact instrument locations.

Official sources used:

- The Highlands resort stats: https://www.highlandsharborsprings.com/media-room/resort-stats
  - Base elevation: 773 ft; summit elevation: 1,325 ft
- Loon Mountain stats: https://www.loonmtn.com/mountain-stats
  - Base elevation: 860 ft; summit of North Peak: 3,050 ft
- Sugarloaf mountain information: https://www.sugarloaf.com/mountain-info
  - Summit elevation: 4,237 ft; vertical drop: 2,820 ft; base entered as approximately 1,417 ft by arithmetic inference because the captured official page did not expose an explicit base-elevation field.
- Sunday River Meet the Peaks: https://www.sundayriver.com/the-mountain/8-peaks
  - The official peak table lists elevations for White Cap, Locke, Barker, Spruce, North Peak, Aurora, Oz, and Jordan. A high-elevation row was added for Oz Peak at 3,150 ft because it is the highest listed Sunday River peak in the captured table. The existing primary base/forecast-point row remains DEM fallback pending an official base/station elevation.
- Boyne Mountain mountain stats: https://www.boynemountain.com/mountain-stats
  - The official page confirms 500 vertical feet in the captured source, but it did not expose explicit base/summit elevations there, so no official elevation rows were added for Boyne Mountain in this pass. This is an unresolved source gap.

### Additional Official Western Ikon Mountain-Info Batch

This pass added official mountain-stat elevation anchors for several remaining single-location western Ikon resorts. These rows are not asserted to be weather instruments unless a source explicitly says so; they are reliable base/top/elevation anchors useful for forecast normalization and future station mapping.

Official sources used:

- Copper Mountain winter mountain stats: https://www.coppercolorado.com/the-mountain/mountain-safety-stats/winter-mountain-stats/
  - Base elevation: 9,712 ft; summit elevation: 12,441 ft
- Brighton Resort about page: https://www.brightonresort.com/about
  - Base elevation: 8,755 ft; top elevation: 10,500 ft
- Crystal Mountain stats and facts: https://www.crystalmountainresort.com/media/mountain-stats-and-facts
  - Base: 4,400 ft; Lower Northway: 3,912 ft; Summit/top of gondola: 6,872 ft; Silver King: 7,012 ft. Crystal’s page also lists individual lift start/end elevations, which may be useful in a later pass if the app wants lift-terminal forecast points.
- Arapahoe Basin official press-kit PDF: https://stgabasin.blob.core.windows.net/arapahoe/uploaded/pdfs/abasin%20press%20kit%20final%20small%201920%20winter.pdf
  - Base elevation: 10,520 ft; summit elevation: 13,050 ft

Unresolved caveat: Alta’s official about page was checked but the captured source text did not expose explicit base/top numbers despite showing the mountain-stats section shell; Alta remains on DEM fallback pending a source-captured official elevation/station page or reliable official PDF/map extraction.

### Additional Official Alterra California Mountain-Info Batch

This pass added official mountain-stat elevation anchors for additional Alterra/Ikon California physical resorts that still had only DEM fallback rows. These official rows should still be read as base/peak elevation anchors rather than instrument metadata unless later source work identifies named weather stations or snow stakes.

Official sources used:

- June Mountain official trail-map / mountain-stats page: https://www.junemountain.com/mountain-information/trail-map
  - Base elevation: 7,545 ft; summit elevation: 10,090 ft
- Big Bear Mountain Resort official trail-map page: https://www.bigbearmountainresort.com/mountain-information/trail-maps
  - Bear Mountain base elevation: 7,140 ft; peak elevation: 8,805 ft
  - Snow Summit base elevation: 7,000 ft; peak elevation: 8,200 ft
  - The same source identifies each as a separate physical mountain within the Big Bear Mountain Resort destination, so rows remain tied to the individual physical resort names already present in `data/resorts.csv`.

Checked but not yet converted into resort-location rows in this pass:

- Blue Mountain Ontario official mountain-stats page: https://www.bluemountain.ca/mountain/mountain-stats
  - The captured source exposes an `Elevation: 720 feet` statistic, which appears to describe vertical/elevation gain rather than an absolute base, summit, or station elevation. Because the field is ambiguous for weather modeling, the existing DEM fallback row was left unchanged.
- Camelback official snow report / conditions page: https://conditions.camelbackresort.com/conditions/
  - The page provides current snow/terrain metrics and base-depth reporting but did not expose a named station or base/summit coordinate/elevation pair in the captured source. Existing fallback/base row remains pending better official station metadata.
- Blue Mountain Resort Pennsylvania official media kit: https://www.skibluemt.com/media-kit/
  - The page confirms the resort positioning around Pennsylvania's highest vertical but did not expose explicit base/summit/station elevations in the captured source text. Existing fallback/base row remains pending better source extraction.

### Additional Official Killington / Pico Mountain-Stats and Snow-Measurement Batch

This pass added a richer official-source profile for Killington because the resort's mountain-stats page exposes several named mountain elevations and an explicit snowfall measurement elevation. This is closer to the weather/snow-station goal than generic base/summit stats, but exact coordinates for the 4,000-foot measurement level were not provided in the captured source.

Official source used:

- Killington mountain stats: https://killington.com/mountain-stats
  - Base Elevation (Skyeship): 1,165 ft
  - Killington Peak: 4,241 ft
  - Skye Peak: 3,800 ft
  - Ramshead Peak: 3,610 ft
  - Snowdon Peak: 3,592 ft
  - Bear Mountain Peak: 3,262 ft
  - Sunrise Mountain Peak: 2,456 ft
  - Pico Mountain Peak: 3,967 ft
  - Snowfall measurement caveat: the page states monthly/annual snowfall is measured at the 4,000-foot level below the summit of Killington Peak. A `weather_station` row was added at 4,000 ft for Killington with approximate coordinates pending an official station coordinate.

Caveat: because the source combines Killington and Pico Mountain in one stats page, the Pico peak row is tied to `Pico Mountain`, but other Killington-area peaks remain under `Killington`. No Pico base or Pico snow-measurement station was identified in this pass.

### Additional Official Alaska / Canadian Rockies / Interior BC Batch

This pass targeted remaining single-location North American resorts where official resort, official PDF, or official regional resort-network pages expose base/top elevations and, in Kicking Horse's case, named snow-report elevation bands. These additions move the data closer to observed snow/weather station coverage, but most rows remain elevation anchors rather than exact instrument coordinates unless explicitly described as snow-station rows.

Official / official-network sources used:

- Alyeska Resort schedule/rates PDF: https://www.alyeskaresort.com/wp-content/uploads/2023/10/2024-schedule-rates.pdf
  - Base elevation: 250 ft; summit elevation: 3,939 ft
- SkiBig3 Banff Sunshine page: https://www.skibig3.com/ski/resorts/banff-sunshine/
  - Base elevation: 5,440 ft; top elevation: 8,943 ft. The same page also labels the snow-condition webcam/report context, but no exact station coordinates were exposed in captured text.
- SkiBig3 Lake Louise page: https://www.skibig3.com/ski/resorts/lake-louise/
  - Base elevation: 5,400 ft; top elevation: 8,650 ft
- SkiBig3 Mt. Norquay page: https://www.skibig3.com/ski/resorts/mt-norquay/
  - Base elevation: 5,350 ft; top elevation: 6,998 ft
- Kicking Horse official mountain-stats page: https://kickinghorseresort.com/discover-kickinghorse/mountain-stats/
  - Bottom of lowest chair/base: 3,900 ft; mid-mountain: 5,646 ft; top of Kicking Horse: 8,218 ft
  - Average-snowfall table location bands: lower mountain 4,263 ft, mid mountain 5,646 ft, alpine snow stations 7,049 ft, summit snow stations 8,033 ft. These were added as `weather_station`, `mid_mountain`, or `snow_stake` rows as appropriate, with approximate coordinates pending station-coordinate publication.
- Fernie Alpine Resort official mountain-stats page: https://skifernie.com/discover-fernie/mountain-stats/
  - Base elevation: 3,450 ft; summit elevation: 7,000 ft
- Kimberley Alpine Resort official mountain-stats page: https://skikimberley.com/discover-kimberley/mountain-stats/
  - Base elevation: 4,035 ft; top elevation: 6,500 ft
- Nakiska official mountain-stats page: https://skinakiska.com/discover-nakiska/mountain-stats/
  - Base elevation: 5,003 ft; top elevation: 7,415 ft
- Panorama official fact sheet: https://www.panoramaresort.com/assets/fact-sheet.pdf
  - Highest elevation: 8,038 ft; vertical: 1,300 m. Base was entered by arithmetic inference from highest elevation minus vertical and is explicitly caveated.
- Revelstoke Mountain Resort official mountain-stats page: https://www.revelstokemountainresort.com/mountain/mountain-stats/
  - Resort village elevation: 512 m / approx. 1,680 ft; Stoke Chair elevation: 2,225 m / approx. 7,300 ft; Sub Peak elevation: 2,340 m / approx. 7,677 ft
- Sun Peaks official trail maps/stats page: https://www.sunpeaksresort.com/ski-ride/the-mountain/trail-maps-stats
  - Village base elevation: 4,116 ft; Mt. Tod summit: 7,060 ft; Burfield summit: 6,824 ft; Burfield base: 3,930 ft; the source also lists additional lift base/top elevations that can be added if the model later wants lift-terminal forecast points.
- SilverStar official home page: https://www.skisilverstar.com/
  - Village elevation: 1,609 m / approx. 5,279 ft; total vertical drop: 760 m. Summit was inferred from village plus vertical and is caveated pending a captured official summit/station source.

Caveats:

- SkiBig3 pages are official regional resort-network pages for Banff Sunshine, Lake Louise, and Mt. Norquay. They were used because they expose consistent mountain stats and live snow-condition context. Resort-owned pages should still be preferred if later extraction reveals station-level metadata.
- Panorama and SilverStar include inferred base/summit values because the captured official source exposed highest/vertical or village/vertical but not both base and summit as explicit absolute elevations. Those rows are marked as inferred in notes.
- Kicking Horse is the strongest station-spectrum addition in this batch because its official page distinguishes lower mountain, mid mountain, alpine snow stations, and summit snow stations with elevations. Coordinates are still approximate.

### Additional Official U.S. / Canada Single-Location Resort Batch

This pass targeted remaining single-location North American resorts with official mountain-stat pages, official FAQs, official PDFs, or official webcam pages. Several rows are still elevation anchors rather than precise observed-weather stations, but Tremblant and Kicking Horse now include explicitly station-like webcam/snow-station rows, and Killington includes an official snowfall-measurement elevation from an earlier pass.

Official sources used:

- Snowbird winter scenic tram: https://www.snowbird.com/activities-events/winter-activities/winter-scenic-tram-rides/
  - Hidden Peak: 11,000 ft; tram vertical: 2,900 ft. Base/Snowbird Center entered as inferred 8,100 ft from the official vertical relationship.
- Snowbasin FAQ: https://www.snowbasin.com/about/faqs/
  - Base Area elevation: 6,316 ft; Mount Ogden summit: 9,570 ft
- Solitude By The Numbers: https://www.solitudemountain.com/mountain-and-village/mountain-information/solitude-by-the-numbers
  - Bottom elevation: 7,994 ft; top elevation: 10,488 ft; total vertical: 2,494 ft
- Winter Park mountain statistics: https://www.winterparkresort.com/the-mountain/mountain-information/statistics
  - Resort base: 9,000 ft; summit: 12,060 ft
  - Sub-area top elevations added for Winter Park, Mary Jane, Vasquez Ridge, Parsenn Bowl/Cirque, and Eagle Wind where listed in the source table.
- Taos mountain information: https://www.skitaos.com/mountain?src=mappery
  - Base elevation: 9,350 ft; summit elevation: 12,481 ft
- Telluride mountain facts: https://tellurideskiresort.com/?spb-section=mountain-facts
  - Base: 8,725 ft; lift-served: 12,515 ft; maximum: 13,150 ft
- Mt. Bachelor mountain stats: https://www.mtbachelor.com/the-mountain/resort-policies-safety/mountain-stats/
  - Lowest elevation: 5,700 ft; top elevation: 9,065 ft
- Sierra-at-Tahoe FAQ: https://sierraattahoe.com/faq/
  - Base elevation: 6,640 ft; summit elevation: 8,852 ft
- Stratton mountain statistics: https://www.stratton.com/the-mountain/mountain-statistics
  - Summit elevation: 3,875 ft; vertical drop: 2,003 ft. Base entered as inferred 1,872 ft pending an explicit official base/station elevation.
- Sugarbush terrain/maps: https://www.sugarbush.com/mountain/terrain-and-maps
  - Lincoln Peak base/summit: 1,575 ft / 3,975 ft
  - Mt. Ellen base/summit: 1,483 ft / 4,083 ft
  - Additional listed peaks: Castlerock 3,812 ft, North Lynx 3,300 ft, Gadd 3,150 ft, Inverness 2,750 ft
- RED Mountain maps/stats: https://www.redresort.com/maps-stats/
  - Base elevation: 1,185 m / 3,887 ft; summit elevation: 2,075 m / 6,807 ft
- Schweitzer winter fact sheet PDF: https://www.schweitzer.com/-/media/schweitzer/pdfs-and-maps/press/schweitzer-winter-fact-sheet-2425.pdf
  - Base elevation: 3,960 ft; summit elevation: 6,400 ft
- Cypress trail maps/stats: https://www.cypressmountain.com/trail-maps-and-stats
  - Cypress Creek Lodge: 915 m / 3,000 ft; Mt Strachan: 1,440 m / 4,720 ft. The lodge row is explicitly typed as `lodge` because the source identifies a named base-area building/elevation rather than a generic resort base.
- Tremblant webcams: https://www.tremblant.ca/mountain-village/webcams
  - South Side webcam: 350 m / approx. 1,148 ft
  - Flying Mile Peak webcam: 590 m / approx. 1,936 ft
  - Summit of the Mountain webcam: 875 m / approx. 2,871 ft

Caveats:

- Snowbird and Stratton base elevations are inferred from official top/vertical relationships, not directly listed as base fields in the captured source. Their notes explicitly mark the inference.
- Winter Park and Sugarbush expose multiple official sub-area/peak elevations. Those rows are useful for forecast-point modeling, but exact coordinates still reuse the resort coordinate until a georeferenced official map or station metadata is added.
- Tremblant webcam rows are station-like official public observation locations by name/altitude, but the official page does not publish exact lat/lon; coordinates remain approximate.

### Additional Official / Industry North America Batch

This pass added more remaining single-location North American resorts using official resort pages where available, and one resort-industry source where the official owner pages did not expose an easily captured Snow Valley stat table. Rows are still distinguished between direct official base/top values, inferred values from official top/vertical relationships, and station-like rows.

Sources used:

- Sun Valley Bald Mountain: https://www.sunvalley.com/the-mountain/bald-mountain
  - Bald Mountain base elevation: 5,750 ft; top elevation: 9,150 ft
- Snowshoe Mountain stats: https://www.snowshoemtn.com/mountain-info/mountain-stats
  - Summit elevation: 4,848 ft; Basin vertical: 800 ft; Western Territory vertical: 1,500 ft. Basin and Western bases are inferred from summit minus the listed verticals because explicit base elevations were not captured.
- Snow Valley / Ski California member resort page: https://skicalifornia.org/resorts/snow-valley-mountain-resort
  - Base elevation: 6,800 ft; summit elevation: 7,841 ft; vertical: 1,041 ft. Ski California is a resort-industry association page and links to official Big Bear Mountain Resort Snow Valley resources; this should be superseded if BBMR republishes a directly captured official Snow Valley stat table.
- Granite Peak trail map/mountain stats: https://www.skigranitepeak.com/mountain-info/trail-map-mountain-stats
  - Base area elevation: 1,242 ft; top elevation: 1,942 ft
- Snowriver mountain stats: https://www.snowriver.com/the-resort/mountain-information/mountain-stats
  - Combined two-mountain elevation range: 1,212 ft to 1,750 ft across Jackson Creek Summit and Black River Basin
- Stoneham mountain stats: https://ski-stoneham.com/en/skiing-riding/mountain-stats/
  - Base: 248 m / 814 ft; summit: 593 m / 1,946 ft
- Mont-Sainte-Anne technical data: https://mont-sainte-anne.com/donnees-techniques-au-mont-sainte-anne/
  - Altitude: 800 m / 2,625 ft; vertical drop: 625 m / 2,050 ft. Base entered as inferred 575 ft.
- Le Massif welcome page: https://www.lemassif.com/en/welcome-to-le-massif-de-charlevoix
  - Highest summit: 806 m / approx. 2,644 ft. No official base/station elevation was captured on this pass, so only a summit row was added and the primary fallback base row remains otherwise unchanged.
- Blue Mountain Resort PA directions page: https://www.skibluemt.com/directions/
  - Official page states 1,543 ft elevation above sea level and 1,082 ft vertical drop. Base entered as inferred 461 ft pending explicit official base/station metadata.

Caveats:

- Snowshoe, Mont-Sainte-Anne, and Blue Mountain PA base rows in this pass include arithmetic inference from official summit/high-elevation plus vertical-drop values. Their CSV notes explicitly state the inference.
- Snowriver is a combined two-mountain destination with Jackson Creek Summit and Black River Basin. The official source lists a combined elevation range rather than per-mountain base/top station coordinates; rows are therefore generic combined lower/highest elevation anchors.
- Le Massif's official source captured a highest summit elevation only; a future pass should search official trail-map PDFs and weather pages for base chalet, summit chalet, and weather-station elevations.

### Additional Southern Hemisphere Official / Industry Batch

This pass targeted Australia and New Zealand resorts that still had only DEM fallback rows. Official resort pages were used where captured. Where direct official resort pages did not expose a machine-readable base/top table, a resort-management PDF or national resort-industry source was used and caveated.

Sources used:

- Hotham official mountain information: https://www.mthotham.com.au/discover/explore/mountain-info/1000
  - Base height: 1,450 m / approx. 4,757 ft; elevation: 1,861 m / approx. 6,106 ft
- Falls Creek Resort Management operations manual: https://corporate.fallscreek.com.au/wp-content/uploads/sites/55/2018/09/FCRM-Operations-Service-Level-Manual-Rev-3.0-4-Jun-2018.pdf
  - Official resort-management source states the resort ranges from 1,200 m to 1,860 m above mean sea level. These were added as lower/upper resort-range elevation anchors, not as named weather-station rows.
- Mt Buller / Snow Resorts Australia resort page: https://asaa.org.au/resorts/mtbuller/
  - States Mt Buller alpine village sits at 1,600 m and the summit is 1,805 m. This is a resort-industry source rather than the resort-owned page and should be superseded by a directly captured Mt Buller official stats page if found.
- Perisher official resort stats: https://www.perisher.com.au/the-station?catid=0&id=3
  - Lowest lifted point / Base Ridge Chair: 1,605 m / 5,266 ft; Mt. Perisher summit height entered at approx. 2,054 m / 6,739 ft from the official stats table.
- NZSki official trade/media page: https://www.skiqueenstown.com/trade-and-media/
  - Coronet Peak: elevation 1,649 m; vertical drop 462 m. Base is inferred as 1,187 m / approx. 3,894 ft.
  - The Remarkables: elevation 1,943 m; vertical drop 468 m. Base is inferred as 1,475 m / approx. 4,839 ft.

Caveats:

- Coronet Peak and The Remarkables base rows are arithmetic inferences from official elevation and vertical-drop values because the captured NZSki text did not expose explicit base elevations.
- Falls Creek rows represent the official resort-management altitude range, not the exact base lodge, mid-mountain, summit, snow stake, or weather station. A later pass should inspect Falls Creek's live weather/snow pages for sensor-specific names.
- Mt Buller uses a reputable national resort-industry source rather than a resort-owned mountain-stat page. It is acceptable as a fallback but should be replaced by official Mt Buller or resort-management evidence if found.
- Thredbo, Mt Hutt, Valle Nevado, Yunding Snow Park, and Mona Yongpyong remain candidates for future official-source enrichment.

### Additional European Alps Official-Source Batch

This pass added official Alps elevation anchors for several large destination rows that still had only DEM fallback rows. Many European pass destinations are marketed valleys or linked ski domains rather than a single physical mountain, so these rows are deliberately labeled as sector, summit, freeride-route, or resort-altitude anchors rather than precise weather stations unless an official source identifies them as an observation point.

Sources used:

- Chamonix valley official/partner visitor guide PDF: https://www.experiencechamonix.com/wp-content/uploads/guide_2025_web.pdf
  - Brévent / Flégère: 1,095 m - 2,525 m
  - Les Grands Montets: 1,235 m - 3,275 m
  - Caveat: `Chamonix Mont-Blanc Valley` is a marketed valley row; rows added here are sector elevation anchors for physical ski areas within the valley, not one single mountain station.
- Zermatt tourism Matterhorn Glacier Paradise base-station page: https://zermatt.swiss/Media/Attraktionen/Talstation-Matterhorn-Glacier-Paradise
  - Zermatt village/base altitude: 1,620 m; Matterhorn Glacier Paradise peak: 3,883 m
- Verbier 4Vallées ski/snowboard page: https://verbier4vallees.ch/en/experiences-in-verbier/ski-and-snowboard
  - Mont-Fort: 3,330 m, highest point of Verbier 4Vallées
- Verbier 4Vallées Mont-Gelé freeride route page: https://verbier4vallees.ch/en/experiences-in-verbier/freeriding/mont-gele
  - Mont-Gelé cable-car/summit area: 3,023 m
  - Official route altitude bands: Mont-Gelé - Chaux 3,003 m to 2,430 m; Mont-Gelé - Tortin 3,003 m to 2,045 m
  - Caveat: La Chaux and Tortin rows are freeride-route elevation anchors, not weather stations.
- Val Thorens official resort page: https://www.valthorens.com/en/decouvrir/la-station-val-thorens/
  - Resort altitude: 2,300 m; Caron 3200 referenced as a high ski-area experience/development point.
- Courchevel official villages page: https://courchevel.com/en/une-station-6-villages
  - Courchevel 1850 village altitude used as primary resort anchor; La Saulire listed as the resort high point at 2,738 m.
- Méribel official hidden-spots page: https://www.meribel.net/en/meribel-best-hidden-spots/
  - Roc de Fer: 2,294 m; Mont Vallon: 2,952 m

Caveats:

- The Chamonix row is inherently a valley/destination abstraction. Future data modeling may want separate physical resorts/sectors for Brévent, Flégère, Grands Montets, Balme/Le Tour, and Les Houches if weather observations need to be tied to precise stations.
- Verbier, Val Thorens, Courchevel, and Méribel rows use official high points or named route endpoints, but not exact sensor coordinates. Coordinates remain approximate until station-level metadata or georeferenced official trail-map extraction is added.
- Other 4 Vallées physical resort rows such as Nendaz, Veysonnaz, and Thyon still need their own official base/top/weather-station research instead of simply inheriting Verbier's Mont-Fort row.

### Additional Austrian Alps Official-Source Batch

This pass targeted remaining Austrian Alps resorts or Austria-linked ski domains with official resort/tourism pages exposing clear altitude anchors. Rows remain elevation anchors unless a source explicitly names a weather, snow, or event/stage location.

Sources used:

- Sölden official ski-area information: https://www.soelden.com/winter/ski-area/information-on-the-ski-area.html
  - Ski area extent: 1,350 m to 3,340 m above sea level
- Ischgl official press release for the Silvretta Arena / Top of the Mountain event: https://www.ischgl.com/001_TVB/PRESSE/3_Archiv/2023/2023-10-24%20TOM%20Easter%20Chuba/PA_TOM_Easter_NinaChuba_24_EN.pdf
  - Silvretta Arena slope altitude: 1,377 m to 2,872 m
  - Top of the Mountain stage / Idalp event location: 2,320 m
- St. Anton / Arlberg official regional tourism page: https://www.bergwelttirol.at/en/winter/skiing-at-the-arlberg
  - Valluga peak: 2,811 m, highest point of the St. Anton/Arlberg ski area
- Kitzsteinhorn official winter press page: https://www.kitzsteinhorn.at/en/service/backstage/press/winter-2025-26-pr15634
  - Kitzsteinhorn–Maiskogel–Lechnerberg elevation range: 768 m to 3,000 m
  - Top of Salzburg / summit station context: approx. 3,029 m
- Tux official Hintertux Glacier page: https://www.tux.at/en/hintertux-glacier/
  - Panorama terrace at 3,250 m
  - Caveat: a lower/base elevation remains less directly source-captured in the official page; primary lower-row notes remain caveated.
- Zillertal Arena official FAQ: https://www.zillertalarena.com/en/information-services/holiday-information/faq/
  - Highest point: Übergangsjoch at 2,500 m
- Mayrhofen official sunshine-skiing story / FAQ: https://www.mayrhofen.at/en/stories/sunshine-skiing-in-the-zillertal
  - Mountopolis reaches up to approx. 2,500 m at Mount Penken

Caveats:

- Sölden, Ischgl, Kitzsteinhorn and Zillertal Arena are large ski-domain rows; their base/top entries represent official ski-area altitude bands rather than individual weather stations.
- Ischgl's Idalp / Top of the Mountain row is a named event/stage elevation anchor, not a weather station.
- Mayrhofen received a Mount Penken high-elevation row, but the primary/base row still needs a direct official base or valley-station value.
- Hintertux Glacier received an official summit/panorama-terrace row; a later pass should locate a directly source-captured official valley station/base elevation.

### Additional Dolomiti Superski / Italian Alps Official-Source Batch

This pass targeted one-row Dolomiti Superski destination rows. Because Dolomiti Superski often markets broad regions rather than single physical ski hills, and because easily captured pages frequently expose official route lowest/highest points rather than weather-station tables, these rows are intentionally labeled as official route/sector elevation anchors. They should not be treated as observed snow/weather stations unless later source work identifies sensor/stake locations.

Sources used:

- Kronplatz / Plan de Corones Via Artis route: https://www.dolomitisuperski.com/en/outdoor~Sentiero-Via-Artis_17752880~
  - Lowest point: 2,005 m; highest point: 2,275 m on the Kronplatz summit plateau
- Arabba / Marmolada Malga Ciapela - Ombretta Pass route: https://www.dolomitisuperski.com/en/SuperSummer/Discover/Regions/3-Zinnen-Dolomites/Attivita/Hike-Galaxy-3Cime~Malga-Ciapela-Ombretta-Pass_57379891~
  - Lowest point: 1,448 m; highest point: 2,699 m
- Alta Badia / Arabba Cherz Plateau route: https://www.dolomitisuperski.com/en/SuperSummer/Discover/Regions/Alta-Badia/Attivita-in-Alta-Badia/Hike-Galaxy-Alta-Badia~Passo-Incisa-e-Altopiano-del-Cherz_67135782~
  - Lowest point: 1,844 m; highest point: 2,080 m
- Cortina / Arabba Sass de Stria route: https://www.dolomitisuperski.com/en/outdoor~Escursione-al-Sass-de-Stria_805072633~
  - Lowest point: 2,183 m; highest point: 2,485 m
- Royal Dolomites Tour across Carezza, Val di Fassa, Obereggen, Val Gardena, Alpe di Siusi, and Arabba/Marmolada: https://www.dolomitisuperski.com/en/SuperSummer/Discover/Hike%20Galaxy~458-Royal-Dolomites-Tour-2025_807953860~
  - Lowest point: 866 m; highest point: 2,247 m. Used as a multi-domain official route anchor for Val Gardena/Alpe di Siusi, Val di Fassa/Carezza, and Val di Fiemme/Obereggen where a more specific station source remains pending.
- Civetta Ronch monolith route: https://www.dolomitisuperski.com/en/SuperSummer/Discover/Regions/Civetta/Attivita/Hike-Galaxy-in-Civetta~I-monoliti-di-Ronch_57379597~
  - Lowest point: 1,446 m; highest point: 1,632 m

Caveats:

- These Dolomiti Superski rows are a weaker station proxy than official snow-report sensor rows. They are still useful because they replace DEM-only elevations with official regional altitude anchors, but they should be superseded by resort-specific base/chalet/top/stake/weather-station metadata when available.
- Several Dolomiti rows describe multi-resort routes or summer route endpoints rather than ski-area boundaries. CSV notes state that distinction so downstream Rails modeling can distinguish forecast anchors from observation stations.
- Remaining Italian Alps targets such as Madonna di Campiglio, Paganella, Monte Bondone, San Martino di Castrozza/Rolle Pass, Ponte di Legno-Tonale, Pejo, Folgarida-Marilleva, Pinzolo, Pila, Monterosa, Cervino, Courmayeur, and La Thuile still need additional official source work.

### Additional Campiglio / Aosta Valley Official-Source Batch

This pass added official altitude anchors for the Campiglio Dolomiti di Brenta interconnected ski area and several Aosta Valley resorts that still had only one fallback row. These are mostly official base/top/mid-mountain anchors rather than exact observation stations.

Sources used:

- Campiglio Dolomiti official Skiarea Madonna di Campiglio page: https://www.campigliodolomiti.it/en/skiarea/inverno/skiarea-madonna-di-campiglio?landing=605
  - The interconnected Madonna di Campiglio, Pinzolo and Folgarida-Marilleva skiarea spans 850 m to 2,500 m. Rows were added to all three physical/destination rows because the official source explicitly identifies them as the three connected areas in the unified ski domain.
- Pila official ski-area page: https://pila.it/en/ski-area/
  - Pila resort/base reached by gondola at 1,800 m; ski area reaches up to 2,700 m.
- La Thuile official Espace San Bernardo page: https://www.lathuile.it/it/il-comprensorio
  - Departure from La Thuile village at 1,441 m; arrival at Les Suches 2,200 m.
- Espace San Bernardo official skirama PDF: https://cms.lathuile.it/uploads/25_Skirama_Espace_San_Bernardo_4e8e59b9fe.pdf
  - Mont Valaisan labeled at 2,891 m; La Thuile at 1,441 m.
- Courmayeur Mont Blanc official Mountain Stats 2024-2025 PDF: https://www.courmayeur-montblanc.com/app/uploads/2024/10/Mountain-stats-2024-2025.pdf
  - Courmayeur altitude: 1,224 m; Snowpark Aretu Area altitude: 2,000 m.
- Valle d’Aosta official Courmayeur Mont Blanc ski area page: https://www.lovevda.it/en/database/5/downhill-skiing/courmayeur/courmayeur-mont-blanc-ski-area/4360?link_id=b0cdbe9d-3179-4b91-87e4-1dbfd6c3a48a
  - Courmayeur at 1,224 m; runs reach Cresta d’Arp at 2,755 m.
- Cervinia / Cervino official event page: https://www.cervinia.it/en/eventi/cervinia-snow-bike-2024
  - Breuil-Cervinia: 2,050 m; Plateau Rosa cable-car elevation: 3,480 m; Plateau Rosa glacier descent start: 3,500 m.

Caveats:

- Campiglio, Pinzolo and Folgarida-Marilleva share the same official skiarea lower/upper altitude range; resort-specific base lodges or weather stations should supersede these generic skiarea anchors when found.
- Cervino rows use official event-route altitude points. Plateau Rosa is a strong high-elevation anchor, but these rows are not asserted as weather stations.
- Courmayeur has an official snowpark-area altitude and Cresta d’Arp high point, but no exact weather-station coordinate was captured.

### Additional Hakuba Valley Official-Source Batch

This pass added official Hakuba Valley course-elevation anchors for the Hakuba Valley member resorts that still had only one DEM fallback row. Hakuba Valley's official resort-info page publishes each resort's course-details table with lowest/highest elevation and links to the physical resort websites. These rows are reliable resort/course elevation anchors, not exact sensor locations.

Source used:

- Hakuba Valley official snow resort info: https://www.hakubavalley.com/en/ski_resort_info_en/
  - Jigatake Snow Resort: lowest 940 m; highest 1,200 m
  - Kashimayari Snow Resort: lowest 830 m; highest 1,320 m
  - White Resort Hakuba Sanosaka: lowest 740 m; highest 1,200 m
  - ABLE Hakuba Goryu: lowest 750 m; highest 1,676 m
  - Hakuba 47 Winter Sports Park: lowest 820 m; highest 1,614 m
  - Hakuba Happo-One Snow Resort: lowest 760 m; highest 1,831 m
  - Hakuba Iwatake Snow Field: lowest 750 m; highest 1,289 m
  - Tsugaike Mountain Resort: lowest 800 m; highest 1,704 m
  - Hakuba Norikura Onsen Snow Resort: lowest 800 m; highest 1,598 m
  - Hakuba Cortina Snow Resort: lowest 872 m; highest 1,402 m

Caveats:

- Hakuba Valley rows are official course-elevation anchors. The page does not publish lat/lon for the lowest/highest course points, nor does it identify those points as weather stations or snow stakes.
- The source is an official regional pass/resort organization page that links to each member resort's website. Later station-level work should inspect each resort's live snow-report/weather page for named base/top/stake measurement locations.

### Additional Niseko / Hokkaido / Northern Japan Batch

This pass added source-backed rows for additional Japanese resorts that still had only one DEM fallback row. The strongest entries are Niseko's official shared summit/weather-status context and Furano's official Prince Snow Resorts base/peak table. Rusutsu uses an official resort blog with a peak elevation. Zao and APPI remain partly caveated because the captured official pages did not expose a clean base/top stats table.

Sources used:

- Niseko United official overview: https://www.niseko.ne.jp/en/niseko/
  - States Niseko United comprises four resorts on one mountain, Niseko Annupuri, at 1,308 m. Shared summit rows were added for Annupuri, Grand Hirafu, Hanazano, and Niseko Village.
- Niseko United official weather/lift status: https://www.niseko.ne.jp/en/niseko-lift-status/
  - Reports conditions by Annupuri, Niseko Village, Grand Hirafu, Hanazono, and includes a Mountain base context. Base/weather-station rows were added but marked approximate because exact station elevation/coordinates were not captured.
- Furano / Prince Snow Resorts official page: https://www.princehotels.com/en/ski/furano/index.html?gad_source=1
  - Elevation table: Base 235 m; Peak 1,074 m; vertical descent 839 m.
  - The same page identifies First Track location as Furano Zone Summit Start, so a high-elevation summit-start row was added using the official peak elevation.
- Rusutsu official resort blog: https://rusutsu.com/en/blog/032/
  - East No.1 gondola reaches the peak at 868 m elevation.
- Zao Onsen official ski page: https://zao-spa.or.jp/english/ski/
  - Identifies official course/ski-area context including lowest-altitude Omori Giant and the Juhyo/Snow Monster area, but the captured page did not expose a clean numeric base/top table. Rows remain caveated and should be superseded by exact official station/elevation data if found.
- APPI Resort official page: https://www.appi.co.jp/en/
  - Identifies APPI Resort at the foot of Maemori Mountain. Numeric base/top values remain caveated pending a direct official course-elevation table.

Caveats:

- Niseko rows attach the same shared Mt. Niseko Annupuri summit to the four physical resort rows because the official source describes them as four resorts on one mountain. Resort-specific lower bases still need exact source-captured elevations.
- Zao and APPI received approximate lower/high anchors to document the best official source found this pass, but remain priority items for future exact station/elevation research.

### Additional Shiga Kogen Official Live-Status / Elevation Batch

This pass added official Shiga Kogen Mountain Resort minimum/highest altitude rows for the Shiga Kogen physical ski-area rows that still had only one fallback row. Shiga Kogen's official live lift/status pages publish per-area data tables with highest altitude, minimum altitude, and altitude difference. These are strong official course/elevation anchors and the pages also carry weather/snowfall status fields, but they do not publish exact station coordinates in captured text.

Official sources used:

- Okushiga Kogen: https://shigakogen-ski.or.jp/lift/okushigakogen/index-en.html — minimum 1,470 m; highest 2,000 m
- Yakebitaiyama: https://www.shigakogen-ski.or.jp/lift/yakebitaiyama/index-en.html — minimum 1,555 m; highest 2,000 m
- Kumanoyu: https://shigakogen-ski.or.jp/lift/kumanoyu/index-en.html — minimum 1,690 m; highest 1,960 m
- Ichinose Family: https://shigakogen-ski.or.jp/lift/ichinosefamily/index-en.html — minimum 1,620 m; highest 1,940 m
- Terakoya: https://shigakogen-ski.or.jp/lift/terakoya/index-en.html — minimum 1,905 m; highest 2,060 m
- Takamagahara Mammoth: https://shigakogen-ski.or.jp/lift/takamagahara/index-en.html — minimum 1,670 m; highest 1,900 m
- Giant: https://shigakogen-ski.or.jp/lift/giant/index-en.html — minimum 1,330 m; highest 1,590 m
- Hasuike: https://www.shigakogen-ski.or.jp/lift/hasuike/index-en.html — minimum 1,505 m; highest 1,590 m
- Maruike: https://www.shigakogen-ski.or.jp/lift/maruike/index-en.html — minimum 1,465 m; highest 1,565 m
- Hoppo Bunadaira: https://www.shigakogen-ski.or.jp/lift/hoppobunadaira/ — minimum 1,330 m; highest 1,570 m
- Higashidateyama: https://www.shigakogen-ski.or.jp/lift/higashitateyama/index-en.html — minimum 1,540 m; highest 1,970 m
- Nishidateyama: https://shigakogen-ski.or.jp/lift/nishitateyma/ — minimum 1,460 m; highest 1,730 m
- Ichinose Diamond: https://www.shigakogen-ski.or.jp/lift/ichinosediamond/index-en.html — minimum 1,615 m; highest 1,700 m
- Ichinose Yamanokami: https://www.shigakogen-ski.or.jp/lift/ichinoseyamanokami/index-en.html — minimum 1,595 m; highest 1,700 m
- Tannenomori Okojo: https://www.shigakogen-ski.or.jp/lift/tannenomoriokojo/index-en.html — minimum 1,660 m; highest 1,815 m
- Yokoteyama / Shibutoge: https://shigakogen-ski.or.jp/lift/yokoteyama-shibutoge/index-en.html — minimum 1,705 m; highest 2,307 m

Caveats:

- The official pages include live weather, temperature, and snowfall fields, but the captured data does not identify exact sensor coordinates. Rows therefore use existing resort forecast coordinates and are marked approximate.
- Yokoteyama's official page covers Yokoteyama and Shibutoge together. The current data has a `Yokoteyama Ski Area` row but not a separate Shibutoge row, so the combined official altitude range is attached to Yokoteyama only.
- The global Shiga Kogen about page states the full resort spans 1,325 m to 2,307 m across 18 ski areas; this batch prefers the per-area pages where available.

## North America official weather/elevation enrichment batch — Whistler Blackcomb, Stevens, Alta, Eldora, Snoqualmie

Sources checked and changes made:

- Whistler Blackcomb official mountain information: https://www.whistlerblackcomb.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Used for official resort base elevation, highest lift-accessed elevation, Whistler Peak elevation, and Blackcomb natural-summit context.
  - Caveat: the official page is a resort-wide two-mountain page and does not publish separate station coordinates for the weather/camera locations in crawlable text. Whistler and Blackcomb rows therefore retain approximate resort-level coordinates for base/summit/forecast references.
- Tourism Whistler stats/facts: https://www.whistler.com/about-whistler/stats-facts/
  - Used as a destination-authority cross-check for Creekside elevation and separate Whistler/Blackcomb top elevations.
  - Caveat: Tourism Whistler is reliable destination data, but not the ski area's live weather telemetry source.
- Stevens Pass official mountain information: https://www.stevenspass.com/the-mountain/about-the-mountain/mountain-info.aspx
  - Used for official base elevation and highest elevation.
- Stevens Pass official weather report: https://www.stevenspass.com/the-mountain/mountain-conditions/weather-report.aspx
  - Confirms the resort exposes Base Weather, Mid Mountain Weather, and Peak Weather forecast tabs.
  - Caveat: the crawlable page identifies the tabs but did not expose a reliable mid-mountain station elevation; the mid-mountain row is retained with blank elevation rather than deriving one.
- Alta official weather and snow report: https://www.alta.com/weather
  - Used for official Base, Mid Mountain, and Top of Collins weather elevations.
- Alta official snowfall history/season recap material: https://www.alta.com/stories/best-worst-season
  - Used for the Collins Study Plot / snow-stake elevation and its role in snowfall observations.
  - Caveat: station-specific coordinates were not published in the crawled source, so existing resort coordinates are retained as approximate.
- Eldora official map/conditions navigation: https://www.eldora.com/the-mountain/maps/alpine-trail-map/
  - Confirms official snow report / weather forecast navigation, but did not expose station names/elevations in crawlable text.
- U.S. Forest Service Eldora Mountain Resort Ski Area page: https://www.fs.usda.gov/r02/arp/recreation/eldora-mountain-resort-ski-area
  - Used as reliable government reference for Eldora ski-area latitude/longitude and 10,800 ft elevation.
- Colorado.com Eldora listing: https://www.colorado.com/skiing-snowboarding/eldora-mountain-resort/
  - Used as a reliable public tourism fallback for Eldora base elevation where official Eldora crawlable text did not expose a base elevation.
  - Caveat: Colorado.com reports terrain/elevation values that differ from some third-party ski databases; retained with source-specific notes.
- Summit at Snoqualmie official Alpental page: https://www.summitatsnoqualmie.com/alpental
  - Used for official Alpental vertical-footage source.
- Summit at Snoqualmie official Alpental mountain report: https://www.summitatsnoqualmie.com/alpental/mountain-report
  - Confirms Alpental weather-station section and explains overnight weather data are automatically updated from Northwest Avalanche Center telemetry.
- Northwest Avalanche Center precipitation data portal: https://nwac.us/data-portal/accumulations/precipitation/
  - Used for Alpental Base telemetry elevation and latitude.
  - Caveat: the search/crawl result exposed latitude and elevation but not longitude; existing resort longitude is retained and marked approximate.
- Summit at Snoqualmie official three-summit page and trail maps: https://www.summitatsnoqualmie.com/summit and https://www.summitatsnoqualmie.com/trail-maps
  - Used to split the aggregate Summit Central / Summit West / Summit East row into source-backed area references.
  - Caveat: official crawlable pages identified the areas/maps but did not expose reliable base-area elevations; elevations remain blank except for the existing aggregate DEM fallback row.

Methodology note for this batch: when official weather pages identified station tiers but did not publish coordinates, rows retain existing resort/base coordinates and explicitly mark them approximate. Derived values are avoided except for Alpental Top, where the notes state the derivation from official vertical feet plus NWAC base elevation.

## North America official conditions/mountain-stat enrichment batch — Blue Mountain, Boyne, Camelback, Dollar Mountain

Sources checked and changes made:

- Blue Mountain official mountain hub: https://www.bluemountain.ca/mountain
  - Confirms official conditions report, webcams, maps, and mountain-stats links.
- Blue Mountain official Mountain Stats page: https://www.bluemountain.ca/mountain/mountain-stats
  - Reports a 720 ft elevation figure. Caveat: the page does not distinguish base vs summit vs weather station, so this is stored as an `other` context row while the primary base row keeps its DEM fallback elevation.
- Boyne Mountain official Mountain Report: https://www.boynemountain.com/mountain-report
  - Confirms official snow conditions, lift status, and weather forecast page.
- Boyne Mountain official Mountain Stats: https://www.boynemountain.com/mountain-stats
  - Reports 500 vertical feet and lift vertical figures. Caveat: no crawlable official base/summit elevation was found, so no base/summit elevation was derived from the official vertical stat.
- Camelback official snow report and conditions pages: https://www.camelbackresort.com/snow-report-conditions and https://conditions.camelbackresort.com/conditions/
  - Confirms official snow report, weather/live-cam links, base depth, snowfall, and lift/trail status.
- TopoZone Camelback Mountain topographic reference: https://www.topozone.com/pennsylvania/monroe-pa/summit/camelback-mountain-8/feed/
  - Used as reliable map fallback for Camelback Mountain summit coordinates/elevation because the official resort conditions page did not expose base/summit station elevations.
- Sun Valley official Dollar Mountain page: https://www.sunvalley.com/the-mountain/dollar-mountain/
  - Used for official Dollar Mountain base elevation, top elevation, vertical, conditions, and webcam/mountain-report links.

Caveat for this batch: several lower-elevation eastern/Midwest resort pages publish live conditions but not station elevations in crawlable HTML. For those resorts, source-backed conditions/weather rows were added with blank elevation rather than inventing or deriving station heights.

## Japan official elevation / weather-status enrichment batch — Shiga Kogen, Myoko, Arai, Mt.T, Nekoma

Sources checked and changes made:

- Shiga Kogen Sunvalley official live-status page: https://shigakogen-ski.or.jp/lift/sunvalley/index.html
  - Used for Sun Valley Ski Area minimum altitude, highest altitude, and live weather/temperature/snowfall-status context.
  - Caveat: the live status page reports area-level weather/snowfall, not a separately geolocated weather station.
- Shiga Kogen Yokoteyama/Shibutoge official live-status page: https://www.shigakogen-ski.or.jp/lift/yokoteyama-shibutoge/
  - Used for Shibutoge/Yokoteyama minimum and highest altitudes plus live weather/temperature/snowfall-status context.
  - Caveat: the repository has a separate `Shibutoge Ski Area` row; the official Shiga Kogen source is an area page combining Yokoteyama and Shibutoge, so notes identify the combined source explicitly.
- Mt.T by Hoshino Resorts official page: https://tanigawadake-joch.com/en/mt-t/
  - Used for highest ski-resort elevation and official conditions/lift/live-camera/avalanche-info context.
- Gunma official tourist guide for Mt.T: https://www.visit-gunma.jp/en/spots/mt-t-by-hoshino-resorts/
  - Used for ropeway/ski-area base elevation at Tenjindaira Station.
- Prince Hotels / Ikon announcement PDF including Myoko Suginohara: https://www.princehotels.com/wp-content/uploads/2025/10/release-20251022-1.pdf
  - Used for Myoko Suginohara official top elevation and vertical/elevation difference. Base elevation is derived from those official figures and marked as derived in notes.
- Lotte Arai official resort homepage: https://www.lottehotel.com/prerendered/arai-resort/en/index.html
  - Used for official weather-report / snow-season context.
- Japan Travel official Lotte Arai page: https://www.japan.travel/en/sports/snow/top-recommendations/lotte-arai-resort/
  - Used for 1,429 m Mt. Okenashi/top elevation context.
- SnowStash Lotte Arai snow report: https://snowstash.com/japan/chubu/lotte-arai/snow-report
  - Used as a fallback for Lotte Arai base elevation where official crawled pages did not expose base elevation. Marked as fallback.
- Hoshino Resorts Nekoma Mountain English page: https://www.nekoma.co.jp/englp/
  - Used for official elevation range 700–1,338 m / 2,297–4,390 ft and snow/deep-area context.

Methodology note for this batch: Japanese resort pages often publish area-level live weather/snowfall but omit sensor coordinates. Where this occurred, the CSV keeps existing resort coordinates and marks them approximate. Derived base elevations were used only where an official top elevation and vertical/elevation difference made the base calculation transparent.

## Italian Alps / Dolomites elevation and live-report enrichment batch

Sources checked and changes made:

- 3 Zinnen Dolomites official live-info PDF: https://www.dreizinnen.com/live-info/dreizinnen_dolomites_liveinfo.pdf
  - Used for valley and mountain snow-height elevations and official live snow/operations context.
- Skirama Alpe Cimbra / Folgaria / Lavarone page: https://www.skirama.it/it/alpe-cimbra-folgaria-lavarone
  - Used for official network context and upper lift/ski-area elevation; lower elevation is retained from regional ski-area summary and marked approximate.
- Dolomiti-ski Alpe Lusia / San Pellegrino page: https://www.dolomiti-ski.it/en/ski-areas/alpe-lusia-san-pellegrino/
  - Used for official 1,190–2,517 m ski-area altitude range and Passo San Pellegrino elevation.
- Monte Bondone snow report fallback: https://www.skiresort.info/ski-resort/monte-bondone/snow-report/
  - Used for base/mountain snow-report elevations where a crawlable official Monte Bondone altitude source was not found.
- Monte Bondone weather-report PDF: https://www.ilmeteo.it/pdf/meteo-monte-bondone-eng.pdf
  - Used for weather-report context; no station coordinates exposed.
- Paganella official snow/weather page: https://www.paganella.net/en/snow-weather
  - Used for official weather, summit live conditions, snow, and avalanche-risk report context.
- Paganella official lift status and ski map: https://www.paganella.net/it/live/impianti-orari and https://www.paganella.net/files/getbyid/Ski_Map_2023%2C1052.pdf
  - Used for Cima Paganella and upper lift elevation references.
- Pejo / Val di Pejo official ski-area pages: https://www.termepejo.it/en/val-di-pejo/ski-area-and-pejo-3000/ and https://www.visitvaldipejo.it/en/skiarea-pejo3000
  - Used for Pejo 3000 summit/upper ski-area context.
- Ponte di Legno-Tonale official ski-area, Passo Tonale, and Ponte di Legno pages:
  - https://www.pontedilegnotonale.com/en/pontedilegno-tonale-skiing/pontedilegno-tonale-ski-area/
  - https://www.pontedilegnotonale.com/en/pontedilegno-tonale-what-to-see/passo-tonale/
  - https://www.pontedilegnotonale.com/en/pontedilegno-tonale-what-to-see/ponte-di-legno/
  - Used for lower ski-area elevation, top-of-mountain elevation, Passo Tonale elevation, and Ponte di Legno town/plateau elevation.
- Dolomiti-ski Gitschberg Jochtal page: https://www.dolomiti-ski.it/en/ski-areas/gitschberg-jochtal/
  - Used for Rio Pusteria–Bressanone/Gitschberg Jochtal ski-area altitude range and Rio di Pusteria village elevation.
- San Martino official slope report and ski map:
  - https://www.sanmartino.com/EN/slopes-and-lifts/
  - https://www.sanmartino.com/sanmartino/documenti-files/mappe/skimap-2025-ski-area-san-martino-di-castrozza-p-rolle.pdf
  - Used for real-time slope/lift report context. Passo Rolle elevation was added from a reliable pass reference because the official slope-report crawl did not expose pass elevation in text.

Caveat for this batch: several Italian sources publish area-wide altitude ranges rather than exact weather-station coordinates. Rows therefore retain existing resort-level coordinates unless a source publishes a named pass/town/area point; notes identify approximate coordinates and distinguish forecast/elevation references from true sensors.

## APAC / Upper Midwest / Andes weather and elevation enrichment batch

Sources checked and changes made:

- Lutsen Mountains official trail-map/statistics page: https://www.lutsen.com/mountain-info/trail-map-stats
  - Used for official mountain-stat context including vertical rise, lift-served vertical, skiable acreage, annual snowfall, snowmaking acreage, and lift roster.
- Lutsen Mountains official daily snow report: https://www.lutsen.com/mountain-info/daily-snow-report
  - Used for official weather, snowfall, mountain/lift/trail status, and per-mountain operational-report context.
- USFS / Superior National Forest Lutsen Mountains Draft EIS PDF mirror: https://wtip.org/wp-content/uploads/2022/02/Lutsen-Mountains_Ski_Area_Expansion_Project_Draft_EIS_September_2021.pdf
  - Used as a reliable government-source fallback for approximate Lutsen existing ski-area elevations: about 1,000 ft at the base of Caribou Express and about 1,680 ft at Moose Mountain summit. Caveat: not an official resort snow-station source and coordinates are approximate.
- Thredbo official winter trail map PDF: https://www.thredbo.com.au/wp-content/uploads/2023/05/Thredbo-Winter-Trail-Map.pdf
  - Used for Thredbo base/Valley Terminal elevation of 1,365 m, Central Spur/Eagles Nest area at 1,930 m, and Australia’s highest lifted point / Thredbo Community Bell at 2,037 m.
- Thredbo official weather-report endpoint: https://www.thredbo.com.au/weather-report
  - Used for live weather-report context. Caveat: station coordinates/elevations were not exposed in crawlable text, so a separate weather-station row uses approximate base coordinates and blank elevation.
- Mt Hutt official weather report: https://www.mthutt.co.nz/weather-report
  - Used for official Mt Hutt live weather, webcam, and lift/trail status context.
- Mt Hutt Skiresort.info snow report fallback: https://www.skiresort.info/ski-resort/mt-hutt/snow-report/
  - Used for base/mountain elevations of 1,438 m / 2,086 m because the official Mt Hutt page did not expose crawlable base/summit elevation metadata.
- Valle Nevado official mountain report: https://www.vallenevado.com/en/mountain-report/
  - Used for official current weather, four-day forecast, snowfall totals, total season snow, road status, wind, UV, humidity, visibility, open slopes/lifts, and the explicit 3,000 m snow-level reporting context.
- Valle Nevado OnTheSnow fallback: https://www.onthesnow.com/santiago/valle-nevado/skireport
  - Used only for terrain range 3,000–3,670 m because the official mountain report did not expose a summit elevation.
- Yongpyong official ski/board overview: https://yongpyong.co.kr/eng/skiNboard/overview.do
  - Used for official slope/lift statistics and per-slope vertical-difference context.
- Yongpyong official slope map: https://www.yongpyong.co.kr/eng/skiNboard/slopeMap.do
  - Checked for official named zones and map context.
- Yongpyong Skiresort.info fallback: https://www.skiresort.info/ski-resort/yongpyong-resort/
  - Used for 745–1,450 m elevation range because official crawlable pages exposed slope vertical differences but not a concise base/summit elevation range.
- Genting Resort Secret Garden / Yunding Snow Park Skiresort.info fallback: https://www.skiresort.info/ski-resort/genting-resort-secret-garden/
  - Used for 1,702–2,100 m elevation range and resort operating context because official Secret Garden/Yunding Snow Park weather/snow pages were not reliably crawlable.
- Genting Resort Secret Garden Snow-Online snow report fallback: https://www.snow-online.com/snow-report/ski-resort/genting-resort-secret-garden.html
  - Used for snow-report context only where official crawlable weather/snow reporting metadata could not be found.

Caveat for this batch: the goal is to map actual weather/snow reporting points. Some resorts in this batch publish live weather/snow reports but do not publish sensor coordinates or per-station elevations in crawlable official text. In those cases, rows distinguish official report context from fallback elevation ranges, retain approximate coordinates, and avoid inventing station precision.

## Alps remaining single-location enrichment batch

Sources checked and changes made:

- Andermatt-Sedrun-Disentis official snow-report context: https://www.andermatt-sedrun-disentis.ch/en/stories/snow-report
- Andermatt-Sedrun-Disentis partner/fallback snow report: https://www.esquiades.com/en/skiresort/ski-arena-andermatt-sedrun-disentis/
  - Used for base/summit elevation fallback where official crawlable station elevations were not exposed.
- Brides-les-Bains official 3 Vallées access page: https://www.brides-les-bains.com/hiver/en/skiing/les-3-vallees-ski-area/
- Les 3 Vallées official weather/snow hub: https://www.les3vallees.com/en/live/weather
- Les 3 Vallées official by-the-numbers PDF: https://press.les3vallees.com/media/download/by-the-numbers.pdf
  - Used for Brides-les-Bains / Saint-Martin-de-Belleville / Orelle shared-domain caveats where the physical village row is an access point into the wider 3 Vallées domain rather than a distinct snow station.
- Crans-Montana official ski page: https://www.crans-montana.ch/en/ski
  - Used for official altitude range of 1,500–3,000 m and ski-area context.
- Grandvalira official weather/snow page: https://www.grandvalira.com/en/weather-forecast-grandvalira
- Grandvalira official slopes/sectors page: https://www.grandvalira.com/en/resort/slopes
  - Used for official sector/weather context and the Solanelles 2,500 m reference. Caveat: Grandvalira is a multi-sector domain; one group-level resort row cannot fully represent every physical sector station.
- Hochfügen official weather page: https://www.hochfuegenski.com/en/live-news/weather/
- Hochzillertal official page: https://www.hochzillertal.com/en/
- Hochzillertal regional snow report: https://zillertal-online.at/en/snow-reports/schneebericht-hochzillertal-kaltenbach.html
- KitzSki official snow report: https://www.kitzski.at/en/current-info/kitzski-snow-report.html
- Hahnenkamm topographic fallback: https://en.wikipedia.org/wiki/Hahnenkamm%2C_Kitzb%C3%BChel
- Lech Zürs official live-updates page: https://www.lechzuers.com/en/safety
- Lech Zürs official webcams page: https://www.lechzuers.com/en/live-infos/webcams
- Les Menuires official 3 Vallées weather/snow page: https://www.les3vallees.com/en/live/weather/les-menuires
  - Used for official Les Menuires 1850 m and Pointe de la Masse 2800 m reporting levels.
- Megève official ski-area tourism context: https://www.megeve-tourisme.fr/en/winter/skiing-snowboarding/ski-areas/
- Megève SnowTrex fallback weather/snow report: https://www.snowtrex.ie/france/megeve/le_mont_darbois/weather.html
  - Used only because official crawlable station/elevation metadata was limited.
- Monterosa Ski fallback resort/elevation page: https://www.skiresort.info/ski-resort/monterosa-ski/
- Monterosa weather-report PDF: https://www.ilmeteo.it/pdf/meteo-monterosa-ski-eng.pdf
- Nendaz official tourism/ski page: https://www.nendaz.ch/fr/
- 4 Vallées shared snow-report fallback: https://www.skiresort.info/ski-resort/4-vallees-verbier-la-tzoumaz-nendaz-veysonnaz-thyon/snow-report/
  - Used for Nendaz, Veysonnaz, and shared 4 Vallées upper-context rows where official individual station metadata was not exposed.
- Orelle official live page: https://www.orelle.net/station-ski/live
- Orelle official 3 Vallées weather/snow page: https://www.les3vallees.com/en/live/weather/orelle
- Saint-Martin-de-Belleville / Belleville valley official guide PDF: https://static.st-martin-belleville.com/files/praktische-zomergids-fr-en.pdf
- Silvretta Montafon official snow report: https://www.silvretta-montafon.at/en/snow-report
- Skicircus Saalbach official ski-resort page: https://www.saalbach.com/en/winter/ski-resort
- Fieberbrunn / Skicircus official snow report: https://www.fieberbrunn.com/en/service/newsletter-snowreport/Snow-report
- Skicircus Bergfex fallback elevation/snow page: https://www.bergfex.at/fieberbrunn/
- Spieljochbahn official page/snow-report context: https://www.spieljochbahn.at/en/
- Engadin St. Moritz Mountains official mountain-railways/weather/webcam page: https://www.mountains.ch/en/mountains-railways/
- St. Moritz official high-altitude-training PDF: https://api.stmoritz.com/fileadmin/user_upload/pdf/stmoritz-high-altitude-training_EN_A5.pdf
- Thyon official winter information PDF: https://www.thyon.ch/app/uploads/thyon/2024/11/24-25_hiver-informathyon_low.pdf
- Thyon Bergfex fallback snow report: https://www.bergfex.ch/thyon-4-vallees/schneebericht/
- Veysonnaz FIS event/weather fallback: https://medias4.fis-ski.com/pdf/2016/SB/7776/2016SB7776RLR0.pdf
- Warth-Schröcken official snow report: https://www.warth-schroecken.at/en/winter/ski-area/snowreport.html
  - Used for official named live points and elevations, including Weather station Salober at 2,050 m.

Caveat for this batch: many European resort pages expose current weather/snow reports by JavaScript widgets or PDFs, while source HTML does not provide stable station coordinates. Rows therefore prioritize official named reporting levels where available, use official pages for weather/snow context, and mark fallback elevation/coordinate assumptions explicitly in notes.

## Typing normalization pass

After the major enrichment batches, several rows represented official minimum/base or summit reporting levels but were still typed as generic `forecast_point` or `weather_station`. These were normalized without changing the underlying source evidence:

- Shiga Kogen sub-area rows whose official live-status pages identify minimum altitude and highest altitude were normalized to `base` + `summit` rather than `forecast_point` + `summit`.
- Pila, Cervino Ski Paradise, Courmayeur Mont Blanc, and La Thuile rows whose source notes already identified base/minimum access elevation were normalized to `base`.
- Palisades Tahoe / Alpine Meadows official snow-reporting sensors were normalized so base-level and summit-level sensors are queryable as `base` or `summit` as well as documented in notes.
- Tremblant summit webcam/reporting point was normalized to `summit`.
- San Martino di Castrozza/Rolle Pass `Passo Rolle` row was normalized to `summit`/upper-pass context because it is the higher named forecast/snow reference currently sourced for that grouped resort row.

This pass did not add unsourced coordinates or elevations; it only made already-sourced rows more semantically useful for downstream weather queries.

## Final base/summit audit additions

A final audit identified four resorts without a queryable `base` + `summit` pair. Rows were added only where source evidence or explicit caveats supported them:

- Palisades Tahoe: official snow-reporting methodology article identifies Palisades Base / Patrol Shack at 6,200 ft and Top of Siberia at 8,700 ft, so a queryable `base` row was added alongside the existing snow-stake and summit sensor rows.
- Boyne Mountain: official mountain-stats page reports 500 ft of vertical. A derived upper-context row was added from the approximate base row plus official vertical and explicitly marked non-station/derived.
- Summit Central / Summit West / Summit East: a reliable fallback upper-context row was added from published Summit at Snoqualmie area elevation/vertical references, while official Summit trail-map pages remain the operational source.
- Blue Mountain: the official mountain-stats page exposes an elevation figure of 720 ft but does not distinguish summit/base/weather station in crawlable text. The row is therefore a caveated upper/elevation context, not a confirmed summit sensor.

These additions are designed to make downstream base-vs-upper weather queries possible while keeping uncertainty visible in `notes`.
