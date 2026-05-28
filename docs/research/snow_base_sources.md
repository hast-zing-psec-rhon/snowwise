# Snow Base / Depth Source Research

Research date: 2026-05-26 UTC

## Methodology

This file tracks current snow base/depth source research for every resort in `data/resorts.csv`. The work is intentionally evidence-gated because snow-depth values change frequently and many resort pages render live values through JavaScript widgets that are not visible in static crawls.

Source priority:

1. Official resort snow report, mountain report, weather report, current conditions, or operations page.
2. Official pass/company page if it republishes resort condition data.
3. Government or avalanche-center station pages when the resort says it uses those stations.
4. Reputable aggregators only when official pages do not expose usable current numeric snow-depth data.
5. Source-supported closed/no-snow/off-season/pre-season states may be normalized to `0` inches when the source gives no explicit current numeric base depth, but the observation notes must say the value is policy-derived from closure/no-snow evidence rather than a directly published depth.
6. No value is recorded when the source is stale, ambiguous, unavailable, or model-derived without being clearly a resort-reported base depth.

## Caveats

- Snow base/depth data is time-sensitive. Every source and observation row includes `queried_at`.
- Many official pages were queried but did not expose numeric base-depth values in crawlable text. Those pages are still recorded in `data/snow_report_sources.csv` with `data_found=false`.
- Aggregator values are used only with notes and should be replaced by official API/feed data where possible.
- If a source reports centimeters, values in `data/snow_observations.csv` are converted to inches; decimals may be retained where rounding would obscure the conversion.
- If a resort is closed, in summer operations, or pre-season, a current base depth of `0` is acceptable when the source supports that status. If the same source publishes an explicit nonzero current snow depth despite closure, preserve the explicit numeric value and note the closed/0-open-trails operating status.

## Websites queried so far

- Mammoth Mountain official conditions: https://www.mammothmountain.com/on-the-mountain
- Mammoth Mountain Skiresort.info snow report: https://www.skiresort.info/ski-resort/mammoth-mountain/snow-report/
- Breckenridge official snow/weather report: https://www.breckenridge.com/the-mountain/mountain-conditions/snow-and-weather-report.aspx
- Vail official snow/weather report: https://www.vail.com/the-mountain/mountain-conditions/snow-and-weather-report.aspx
- Park City official snow/weather report: https://www.parkcitymountain.com/the-mountain/mountain-conditions/snow-and-weather-report.aspx
- Park City Skiresort.info snow report: https://www.skiresort.info/ski-holiday-in/park-city-549/snow-report/
- Palisades Tahoe official snow-reporting methodology: https://blog.palisadestahoe.com/operations/how-we-report-snow/
- Deer Valley official mountain report: https://www.deervalley.com/mountain-report
- Deer Valley Skiresort.info snow report: https://www.skiresort.info/ski-resort/deer-valley/snow-report/
- Steamboat official mountain report: https://www.steamboat.com/the-mountain/mountain-report
- OpenSnow Steamboat snow report: https://opensnow.com/location/steamboat/snow-report
- Jackson Hole official mountain report: https://www.jacksonhole.com/mountain-report
- Big Sky official current conditions: https://www.bigskyresort.com/current-conditions
- Big Sky official snow-reporting FAQ: https://www.bigskyresort.com/current-conditions/snow-report-faqs
- Alta official weather/snow report: https://www.alta.com/weather
- Alta official current conditions: https://www.alta.com/status
- Snowbird official mountain report: https://www.snowbird.com/mountain-report/
- Snowbird Skiresort.info snow report: https://www.skiresort.info/ski-resort/snowbird/snow-report/

## Initial usable observations

- Mammoth Mountain: Skiresort.info reported 71 cm base and 292 cm mountain, updated 2026-05-22. Converted to 28 in base and 115 in upper. This is an aggregator fallback because the official Mammoth page did not expose current numeric depth in crawlable text during this pass.
- Alta Ski Area: official Alta current-conditions result reported Base 54 in and 24 hr 0 in, last updated today at 05:00 pm. This was recorded as official resort data.

## Resorts where no usable snow base data was found so far

For the initial batch, no usable current base-depth number was found in crawlable text for:

- Breckenridge
- Vail
- Park City Mountain official page
- Palisades Tahoe current report
- Deer Valley Resort
- Steamboat
- Jackson Hole Mountain Resort
- Big Sky Resort
- Snowbird

## Unresolved questions

- Whether Vail Resorts pages expose a JSON endpoint behind the snow/weather widgets that can be queried directly for Breckenridge, Vail, Park City, Beaver Creek, Keystone, etc.
- Whether Alterra/Ikon resorts expose a stable JSON feed for Mammoth, Palisades Tahoe, Deer Valley, Steamboat, and others.
- Whether licensed feeds such as Mountain News / OnTheSnow, SnoCountry, or The Weather Company are available and cost-effective for complete resort coverage.
- How to distinguish residual nonzero base depths on closed official reports from policy-derived zero values on pages that suppress snow fields entirely.

## Remaining work

This is a partial first batch. The goal is not complete until every resort in `data/resorts.csv` has at least one row in `data/snow_report_sources.csv`, observations are recorded where current usable data is found, all queried sites are documented, and the validation requirements in the goal pass for the full dataset.

## 2026-05-26 continuation: Vail Resorts official snow/weather page batch

Queried the official Vail Resorts `snow-and-weather-report.aspx` pages for the following resorts and recorded them in `data/snow_report_sources.csv`: Afton Alps, Alpine Valley (OH), Attitash Mountain, Beaver Creek, Big Boulder, Boston Mills, Brandywine, Jack Frost, Mt Brighton, Mad River Mountain, Hidden Valley Ski Area (MO), Snow Creek, Paoli Peaks, Wilmot Mountain, Liberty Mountain Resort, Roundtop Mountain Resort, Whitetail Resort, Hidden Valley Resort (PA), Laurel Mountain, Seven Springs, Keystone, Crested Butte, Heavenly, Northstar California, Kirkwood, Stevens Pass, and Stowe.

Findings:

- Alpine Valley (OH) official search result exposed a complete snow-report block: Snow Groomed, 0 in 24-hour snowfall, 0 in 48-hour snowfall, 0 in 7-day snowfall, 42 in base depth, 102 in current season, updated February 25, 2026 at 3:17 PM EST. This was recorded as an observation but marked stale/off-season until the live widget can be confirmed.
- Attitash official page exposed an April 5, 2026 closing report and stated winter 2025/26 has concluded. A blank observation row was recorded to preserve the closed-season state without implying zero snow.
- Afton Alps official pages confirmed the official snow/weather report and that the resort is closed for the 2025/26 winter season, but no numeric base depth was exposed in crawlable text.
- Most Vail Resorts pages opened successfully and confirmed official snow/weather-report URLs, but did not expose current base-depth values in static crawl text. This likely means the live metrics are loaded by JavaScript/My Epic app backing services; the unresolved API-endpoint question remains important.

## 2026-05-26 continuation: Western North America / selected independent and Ikon resorts

Additional official and fallback pages queried and recorded:

- Alpental official Summit at Snoqualmie mountain report: https://www.summitatsnoqualmie.com/alpental/mountain-report
- Palisades Tahoe official snow/weather dashboard: https://www.palisadestahoe.com/mountain-information/snow-weather
- Skiresort.info Palisades Tahoe fallback: https://www.skiresort.info/ski-resort/palisades-tahoe/snow-report/
- Aspen Snowmass official snow report: https://www.aspensnowmass.com/our-mountains/snow-report
- Arapahoe Basin official snow report: https://www.arapahoebasin.com/snow-report/
- Copper Mountain official snow report: https://www.coppercolorado.com/the-mountain/snow-report/
- Snow-Online Copper Mountain fallback: https://www.snow-online.com/snow-report/ski-resort/copper-mountain.html
- Crystal Mountain official mountain report: https://www.crystalmountainresort.com/the-mountain/mountain-report-and-webcams
- OnTheSnow Crystal Mountain fallback: https://www.onthesnow.com/united-states/crystal-mountain-wa/skireport
- Blue Mountain Ontario official mountain hub: https://www.bluemountain.ca/mountain
- Blue Mountain PA official conditions: https://www.skibluemt.com/conditions/
- OnTheSnow Blue Mountain PA fallback: https://www.onthesnow.com/united-states/blue-mountain-ski-area/skireport
- Boyne Mountain official mountain report: https://www.boynemountain.com/mountain-report
- Camelback official conditions pages: https://conditions.camelbackresort.com/conditions/ and https://www.camelbackresort.com/snow-report-conditions
- Brighton official conditions URL: https://brightonresort.com/conditions
- Alyeska official mountain-report URL: https://www.alyeskaresort.com/mountain-report/
- Eldora official conditions/weather URL: https://www.eldora.com/the-mountain/conditions-weather

Usable observations added:

- Alpental: official Summit report exposed 26 in Alpental base depth, 51 in Alpental Mid, and 58 in Alpental Top with 0 in 24h/48h snowfall, from the April 13, 2026 closing report.
- Arapahoe Basin: official A-Basin report exposed 0 in base, 0 in past 24h and 0 in past 48h, with 0 lifts/runs open.
- Crystal Mountain Resort: OnTheSnow fallback, explicitly resort-sourced during official season, reported 36 in base, 54 in mid, 67 in summit on April 12, 2026. Marked stale/off-season.
- Blue Mountain Resort PA: OnTheSnow fallback, explicitly resort-sourced during official season, reported 18 in base and 36 in summit on Dec. 29. Marked stale/off-season.

Caveat: several official pages confirm real snow/conditions dashboards but with live values loaded through widgets or client-side services that static crawling did not expose. Those are retained as source rows with `data_found=false`; fallback aggregator values are marked stale where appropriate.

## 2026-05-26 continuation: Hakuba Valley, Shiga Kogen, Niseko United, and Dolomiti Superski family-source batch

Official family/resort pages queried and recorded:

- Hakuba Valley official WEATHER & SNOW REPORT: https://www.hakubavalley.com/en/weather_en/
- Shiga Kogen official area/lift-status pages, including the common live lift page and individual area pages under https://www.shigakogen-ski.or.jp/lift/
- Niseko United official lift/status/weather page: https://www.niseko.ne.jp/en/niseko-lift-status/
- Snow-Online Niseko United fallback: https://www.snow-online.com/snow-report/ski-resort/niseko-united-hanazono-grand-hirafu-niseko-village-annupuri-.html
- Dolomiti Superski official slope-opening/snow-report hub: https://www.dolomitisuperski.com/en/Ski-area/Slope-opening
- Alta Badia official open lifts/snow report: https://www.altabadia.org/en/open-lifts-snow-report-dolomites
- Arabba official Dolomiti snow report/open-lifts page: https://www.dolomiti.org/en/arabba/impianti/

Coverage added:

- Hakuba Valley rows: ABLE Hakuba Goryu, Hakuba 47, Hakuba Cortina, Hakuba Happo-one, Hakuba Iwatake, Hakuba Norikura Onsen, Jigatake, Kashimayari, Tsugaike, White Resort Hakuba Sanosaka.
- Shiga Kogen rows: Giant, Hasuike, Ichinose Diamond, Ichinose Family, Ichinose Yamanokami, Kumanoyu, Yakebitaiyama, Okushiga Kogen, Yokoteyama, Shibutoge, Takamagahara Mammoth, Nishidateyama, Maruike, Sun Valley, Terakoya, Tannenomori Okojo, Hoppo Bunadaira, Higashidateyama.
- Niseko United rows: Annupuri, Grand Hirafu, Hanazano, Niseko Village.
- Dolomiti Superski rows: 3 Peaks Dolomites, Alpe Lusia – San Pellegrino, Alta Badia, Arabba/Marmolada, Civetta, Cortina d’Ampezzo, Kronplatz/Plan de Corones, Val Gardena/Alpe di Siusi, Val di Fassa/Carezza, Val di Fiemme/Obereggen.

Usable official observations added:

- ABLE Hakuba Goryu: official Hakuba Valley listing exposed 30 cm snow depth, updated 2026-05-03 16:14 JST; converted to 12 in.
- Hakuba Happo-one: official Hakuba Valley listing exposed 0 cm snow depth, updated 2026-05-18 10:08 JST; converted to 0 in.
- Hakuba Iwatake: official Hakuba Valley listing exposed 0 cm snow depth, updated 2026-04-13 11:52 JST; converted to 0 in.

Caveat: the Shiga Kogen and Dolomiti pages are official operational/status sources, but this pass did not expose stable crawlable numeric base-depth values for each component resort. They are recorded as official queried pages with `data_found=false` pending deeper widget/API extraction.

## 2026-05-26 continuation: Big Bear, Australia/NZ, SkiBig3, RCR Canada, and eastern U.S. batch

Official and fallback pages queried and recorded include:

- Big Bear Mountain Resort official mountain information for Bear Mountain, Snow Summit, and Snow Valley: https://www.bigbearmountainresort.com/mountain-information
- Perisher official snow report: https://www.perisher.com.au/reports-cams/reports/snow-report
- Falls Creek official snow report: https://www.skifalls.com.au/snow-report
- Hotham official snow report: https://www.mthotham.com.au/snow-report
- Mt Buller official snow report: https://www.mtbuller.com.au/Winter/snow-weather/snow-report
- Mt Hutt official weather report and Snow-Online fallback: https://www.mthutt.co.nz/weather-report/ and https://www.snow-online.com/snow-report/ski-resort/mt-hutt.html
- Coronet Peak and The Remarkables official weather reports
- SkiBig3 official Banff/Lake Louise/Norquay snow conditions: https://www.skibig3.com/snow-conditions/
- Lake Louise official reports index: https://reports.skilouise.com/
- Fernie, Kicking Horse, Kimberley, Panorama, and Nakiska official condition/snow-report pages, with aggregator fallbacks where official crawlable values were unavailable
- Killington, Loon, Sunday River, Sugarloaf, Pico, Mount Snow, Mount Sunapee, Okemo, Hunter, Crotched, and Wildcat official conditions/snow-report pages

Usable observations added:

- Mt Buller official report: Resort cover `No Snow`, 0 cm last 24 hours, 0 of 19 lifts and 0 of 76 trails; recorded 0 in base equivalent and 0 in 24h.
- Mt Hutt Snow-Online fallback: upper 0 cm / lower 0 cm; recorded 0 in base and 0 in upper, while noting that official Mt Hutt reports SnowSAT methodology but did not expose current numeric values in captured text.
- SkiBig3 official source: Banff Sunshine, Lake Louise, and Mt Norquay each exposed Base 0 in, Overnight 0 in, 24 hours 0 in in the captured official page result; recorded as official zero/off-season observations.
- Fernie Snow-Forecast fallback: upper 0 cm / lower 0 cm, resort closed; recorded 0 in base/upper with caveat.
- Loon OpenSnow fallback: 0 in base depth; recorded cautiously because OpenSnow may combine resort-reported and modeled/estimated data.

Caveat: several official pages confirm the presence of live snow-report widgets or fields, but static captured text did not expose current numeric values. Those pages are recorded as queried sources with `data_found=false`; no numeric observations were inferred from nonnumeric page labels.

## 2026-05-26 continuation: final coverage batch for remaining North America, Japan/Korea, and Europe rows

This batch added at least one recorded queried source for every resort that still lacked source coverage. It prioritized official resort or official regional snow-report hubs and added fallback/government/academic rows only where they were directly relevant.

Official/family sources recorded include:

- Whistler Blackcomb official snow report and official PDF report endpoint for Whistler Mountain and Blackcomb Mountain.
- Sun Valley official mountain report for Sun Valley and Dollar Mountain, with OnTheSnow fallback for a stale Sun Valley base-depth value.
- Official condition/mountain-report pages for June Mountain, Mt. Bachelor, Winter Park, Tremblant, RED Mountain, Revelstoke, Schweitzer, SilverStar, Sun Peaks, Sierra-at-Tahoe, Snowbasin, Snowshoe, Snowriver, Solitude, Stoneham, Stratton, Sugarbush, Taos, Telluride, The Highlands, Le Massif, Mont-Sainte-Anne, Granite Peak, Lutsen, and Yunding Snow Park.
- Official Japanese/Korean resort pages for APPI, Arai, Furano, Mt.T, Myoko Suginohara, Nekoma, Rusutsu, Zao Onsen, and Yongpyong.
- Official European regional/family snow-report hubs: Skirama, Zillertal, Ski Arlberg, Les 3 Vallées, Verbier 4 Vallées, SkiLife, Mont Blanc Natural Resort, Crans-Montana, Grandvalira, Ischgl, KitzSki, Kitzsteinhorn, Megève, Gitschberg Jochtal, San Martino, Silvretta Montafon, Skicircus, Engadin St. Moritz Mountains, Sölden, Valle Nevado, and Matterhorn Paradise.

Usable observations added:

- Sun Valley: OnTheSnow fallback reported 46 in base depth for Mar. 04. Marked stale/off-season and not assigned to a specific location because the captured source did not distinguish Bald Mountain from Dollar Mountain.
- Taos Ski Valley: official Taos weather/snow-report search result exposed Snow Depth: 1 inches. Recorded as official data with location blank because the captured text did not identify base/mid/summit.

Caveat: this batch completes source-row coverage, but many official pages did not expose crawlable current numeric base-depth values. This is a source-discovery dataset, not a complete current measurement dataset. The next engineering step should investigate each vendor's JSON/widget endpoints or licensed feeds for reliable automated refresh.

## 2026-05-26 final gap-fill source rows

A validation pass showed three resorts still lacked a source row. Added official queried sources for:

- Cypress Mountain: https://www.cypressmountain.com/downhill-conditions-and-cams
- Andermatt-Sedrun-Disentis: https://www.andermatt-sedrun-disentis.ch/en/stories/snow-report
- Summit Central / Summit West / Summit East: https://www.summitatsnoqualmie.com/conditions

No crawlable numeric current base-depth value was captured for these rows in this pass, so they are recorded with `data_found=false`.

## 2026-05-26 continuation: closed/no-snow zero-depth policy and gap fill

The project now treats a source-supported closed, no-snow, off-season, or pre-season state as a valid normalized `0` inch current base-depth observation when no explicit numeric base-depth field is published. This is intentionally narrower than “missing value equals zero”: if a page is merely inaccessible, stale, ambiguous, JavaScript-only, or missing the relevant field without closed/no-snow evidence, the depth remains blank.

Additional observations added under this policy or from newly identified current report rows:

- Afton Alps: official Vail Resorts snow/weather context indicated the 2025/26 winter season was closed; recorded 0 in base as a policy-derived closed-season observation.
- Attitash Mountain: official closing report stated the Winter 2025/26 season had concluded; recorded 0 in base as a policy-derived closed-season observation.
- Jackson Hole Mountain Resort: official mountain report was in summer-operations context with no current ski-season base field; recorded 0 in base as an off-season observation.
- Panorama: Skiresort.info fallback reported resort closed with mountain/base depths unavailable/dash; recorded 0 in base with aggregator provenance.
- Perisher: official snow report stated pre-season status and lifts planned to start June 6, 2026, weather permitting; recorded 0 in base as a pre-season observation.
- Park City Mountain: Ski Utah member snow report exposed a current 0 in base and 0 in 24-hour snow row; recorded as current fallback data and preferred over the stale Skiresort.info value.
- Sunday River: official printed mountain report exposed 20 in snow depth, 0 in new snow, and 0 trails open. The explicit 20 in depth was preserved rather than overridden to zero.
- Hakuba Valley component resorts: official Hakuba Valley rows were expanded for Hakuba 47, Cortina, Norikura Onsen, Jigatake, Kashimayari, Tsugaike, and Sanosaka, converting cm snow-depth values to inches.

This policy should be carried into the application refresh workflow: an OpenAI extraction step may output `0` only when it can cite text supporting closed/no-snow/pre-season/off-season or a visible explicit zero value. Otherwise it must output `null` for depth and let the app retain the prior observation or show “unavailable.”

## Final validation summary — 2026-05-26

The final CSV validation run covered all resorts in `data/resorts.csv` and passed the required structural checks.

- Total resorts: 215
- Source rows: 247
- Resorts with at least one source row: 215
- Observation rows: 33
- Resorts with at least one numeric snow observation recorded: 33
- Resorts where a queried source exposed some usable data (`data_found=true`): 38

The complete website-by-website query log is stored in `data/snow_report_sources.csv`; each row records the resort, source name, source type, snow-report URL, queried URL, query timestamp, whether usable data was found, and notes.

### Resorts where no numeric snow-base/depth observation was recorded

For the following resorts, at least one source page was queried and recorded, but no current usable numeric snow-base/depth observation was recorded in `data/snow_observations.csv`. This usually means the official page did not expose crawlable numeric values, the resort was closed/off-season without a clear depth, or only ambiguous/stale/nonofficial data was available.

- 3 Peaks Dolomites
- APPI Resort
- Afton Alps
- Alpe Cimbra Folgaria Lavarone
- Alpe Lusia – San Pellegrino
- Alpine Meadows
- Alta Badia
- Alyeska Resort
- Andermatt-Sedrun-Disentis
- Annupuri
- Arabba/Marmolada
- Arai Mountain Resort
- Aspen Highlands
- Aspen Mountain
- Attitash Mountain
- Bear Mountain
- Beaver Creek
- Big Boulder
- Big Sky Resort
- Blackcomb Mountain
- Blue Mountain
- Boston Mills
- Boyne Mountain
- Brandywine
- Breckenridge
- Brides-les-Bains
- Brighton
- Buttermilk
- Camelback Resort
- Cervino Ski Paradise
- Chamonix Mont-Blanc Valley
- Civetta
- Copper Mountain
- Coronet Peak
- Cortina d’Ampezzo
- Courchevel
- Courmayeur Mont Blanc
- Crans-Montana
- Crested Butte
- Crotched Mountain
- Cypress Mountain
- Deer Valley Resort
- Dollar Mountain
- Eldora Mountain Resort
- Falls Creek
- Folgarida-Marilleva
- Furano Ski Resort
- Giant Ski Area
- Grand Hirafu
- Grandvalira Resorts Andorra
- Granite Peak Resort
- Hakuba 47 Winter Sports Park
- Hakuba Cortina Snow Resort
- Hakuba Norikura Onsen Snow Resort
- Hanazano
- Hasuike Ski Area
- Heavenly
- Hidden Valley Resort (PA)
- Hidden Valley Ski Area (MO)
- Higashidateyama Ski Area
- Hintertux Glacier
- Hochfügen
- Hochzillertal
- Hoppo Bunadaira Ski Area
- Hotham
- Hunter Mountain
- Ichinose Diamond Ski Area
- Ichinose Family Ski Area
- Ichinose Yamanokami Ski Area
- Ischgl
- Jack Frost
- Jackson Hole Mountain Resort
- Jigatake Snow Resort
- June Mountain
- Kashimayari Snow Resort
- Keystone
- Kicking Horse Mountain Resort
- Killington
- Kimberley Alpine Resort
- Kirkwood
- Kitzbühel
- Kitzsteinhorn
- Kronplatz/Plan de Corones
- Kumanoyu Ski Area
- La Thuile - Espace San Bernardo
- Laurel Mountain
- Le Massif de Charlevoix
- Lech Zürs am Arlberg
- Les Menuires
- Liberty Mountain Resort
- Lutsen Mountains
- Mad River Mountain
- Madonna di Campiglio
- Maruike Ski Area
- Mayrhofen
- Megève Ski Area
- Mona Yongpyong
- Mont-Sainte-Anne
- Monte Bondone
- Monterosa Ski
- Mount Snow
- Mount Sunapee
- Mt Brighton
- Mt. Bachelor
- Mt.T
- Myoko Suginohara Ski Resort
- Méribel
- Nakiska Ski Area
- Nekoma Mountain
- Nendaz
- Niseko Village
- Nishidateyama Ski Area
- Northstar California
- Okemo
- Okushiga Kogen Ski Area
- Orelle
- Paganella
- Palisades Tahoe
- Panorama
- Paoli Peaks
- Park City Mountain
- Pejo
- Perisher
- Pico Mountain
- Pila
- Pinzolo
- Ponte di Legno-Tonale
- RED Mountain
- Revelstoke Mountain Resort
- Rio Pusteria – Bressanone
- Roundtop Mountain Resort
- Rusutsu Resort
- Saint-Martin-de-Belleville
- San Martino di Castrozza/Rolle Pass
- Schweitzer
- Seven Springs
- Shibutoge Ski Area
- Sierra-at-Tahoe
- SilverStar Mountain
- Silvretta Montafon
- Skicircus Saalbach Hinterglemm Leogang Fieberbrunn
- Snow Creek
- Snow Summit
- Snow Valley
- Snowbasin
- Snowbird
- Snowmass
- Snowriver Mountain Resort
- Snowshoe Mountain
- Solitude Mountain Resort
- Spieljoch
- St. Anton am Arlberg
- St. Moritz
- Steamboat
- Stevens Pass
- Stoneham Mountain Resort
- Stowe
- Stratton
- Sugarbush Resort
- Sugarloaf
- Summit Central / Summit West / Summit East
- Sun Peaks Resort
- Sun Valley Ski Area
- Sunday River
- Sölden
- Takamagahara Mammoth Ski Area
- Tannenomori Okojo Ski Area
- Telluride
- Terakoya Ski Area
- The Highlands
- The Remarkables
- Thredbo
- Thyon
- Tremblant
- Tsugaike Mountain Resort
- Vail
- Val Gardena/Alpe di Siusi
- Val Thorens
- Val di Fassa/Carezza
- Val di Fiemme/Obereggen
- Valle Nevado
- Verbier
- Veysonnaz
- Warth-Schröcken
- Whistler Mountain
- White Resort Hakuba Sanosaka
- Whitetail Resort
- Wildcat Mountain
- Wilmot Mountain
- Winter Park Resort
- Yakebitaiyama Ski Area
- Yokoteyama Ski Area
- Yunding Snow Park
- Zao Onsen Ski Resort
- Zermatt Matterhorn
- Zillertal Arena

### Validation commands used

A Python CSV validation script checked: exact resort-name matching against `data/resorts.csv`, one or more source rows per resort, allowed `source_type` values, true/false booleans, URL syntax for source/query URLs, numeric-or-blank inch fields, resort-location-name references, and matching source rows for every observation. The final validation reported zero errors.
