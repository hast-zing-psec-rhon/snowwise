# Pass Access Sources

Research date: 2026-05-24

This document supports the CSV seed files only. It does **not** write directly to the Rails database.

CSV files covered:

- `data/resorts.csv`
- `data/resort_groups.csv`
- `data/resort_group_memberships.csv`
- `data/pass_resort_accesses.csv`

## Modeling Rules Applied

- `resorts.csv` is one row per physical ski area, mountain, base area, or provisional weather-comparison target.
- `resort_groups.csv` is one row per marketed/shared-access destination that contains multiple physical resorts, mountains, or ski areas.
- `resort_group_memberships.csv` connects groups to their physical/member rows.
- `pass_resort_accesses.csv` has exactly one target per row: either `resort_name` or `resort_group_name`, never both.
- Shared pass days are targeted to `resort_group_name`, not duplicated onto each member resort.
- Unlimited access rows leave `access_days` blank.
- Limited access rows use integer `access_days`.
- Boolean columns use `true`/`false` strings.

## Official Ikon Pass Sources Used

Primary official Ikon sources:

- Ikon destinations page: https://www.ikonpass.com/en/destinations
- Ikon FAQ: https://www.ikonpass.com/en/faq
- Ikon public website CMS / Sanity CDN destination documents for resort names, official destination grouping, Ikon-published destination coordinates, resort links, and sub-destination membership references.
- Ikon public account product catalog endpoint observed during research for the 2026-2027 full `Ikon Pass` product (`ikonpass2627`), including access buckets indicating 18 unlimited destinations and limited-access destination buckets.

Official Ikon FAQ/source caveats captured in the data:

- Combined/shared-access destinations listed by Ikon FAQ include Aspen Snowmass, Alta Ski Area + Snowbird, SkiBig3, Sun Valley + Dollar Mountain, Killington + Pico, Chamonix Mont-Blanc Valley, Grandvalira Resorts Andorra, Dolomiti Superski, and St. Moritz.
- Ikon FAQ states Alta/Snowbird access is 7 days combined for full Ikon Pass holders with no blackouts.
- Ikon FAQ states Aspen Snowmass access is 7 days combined across Aspen Mountain, Snowmass, Aspen Highlands, and Buttermilk, not 7 days per mountain.
- Ikon FAQ states Killington/Pico access is 7 days combined for full Ikon Pass holders.
- Ikon FAQ states Dolomiti Superski access is combined across 12 member ski areas and has Italy-specific requirements, including third-party liability insurance; FAQ language also notes a November 15-April 15 seasonal access window.
- Ikon FAQ notes Zermatt Matterhorn and Valle d'Aosta/Cervinia are separate Ikon destinations; crossing the border on the same ski day may deduct one day from both destinations.

## Ikon Pass 2026-2027 CSV Expansion Status

The current CSVs include the official Ikon destination universe available from the Ikon public CMS at research time, excluding non-resort/company/adventure-benefit documents that are not straightforward lift-access resort rows:

- Alterra Mountain Company
- CMH Heli-Skiing & Summer Adventures
- Mike Wiegele Heli-Skiing

Ikon rows added/normalized:

- 74 Ikon Pass 2026-2027 access rows plus one explicit Alta/Snowbird combined-access group row, for 74 effective Ikon destination access targets after grouped destinations are normalized.
- 18 full Ikon unlimited-access destinations were modeled as `unlimited_access=true`.
- Remaining full Ikon destinations were modeled as `access_days=7`, `unlimited_access=false`, and `blackout_dates_apply=false`, with group targets where official Ikon content/FAQ indicates shared access.

Important: this file records the clearest full-pass rule only. Ikon Base Pass, Ikon Session Pass, local passes, bonus mountains, Friends & Family tickets, spring access, summer access, lodging-dependent products, and other benefits are intentionally out of scope unless later CSVs add separate rows/products.

## Ikon Resort Groups and Membership Sources

Official Ikon CMS sub-destination references were used for these group memberships:

- Aspen Snowmass — Aspen Mountain, Snowmass, Aspen Highlands, Buttermilk
- Palisades Tahoe — Palisades Tahoe/Olympic Valley, Alpine Meadows
- Big Bear Mountain Resort — Bear Mountain, Snow Summit
- Killington - Pico — Killington, Pico Mountain
- SkiBig3 — Banff Sunshine, Lake Louise Ski Resort, Mt. Norquay
- Niseko United — Grand Hirafu, Hanazono, Niseko Village, Annupuri
- Dolomiti Superski — 12 member ski areas listed in official Ikon/Dolomiti content
- Coronet Peak, The Remarkables, Mt Hutt — Coronet Peak, The Remarkables, Mt Hutt
- The Summit at Snoqualmie — Summit Central / Summit West / Summit East plus Alpental where available from Ikon CMS references
- Sun Valley — Sun Valley/Bald Mountain and Dollar Mountain
- Shiga Kogen Mountain Resort — member ski areas available from Ikon CMS references
- Valle d'Aosta — member ski areas available from Ikon CMS references

Additional group rows were created from Ikon FAQ combined-access language where member-level decomposition remains incomplete or should be revisited:

- Alta - Snowbird — Alta Ski Area + Snowbird
- Chamonix Mont-Blanc Valley — member areas not yet decomposed
- Grandvalira Resorts Andorra — member areas not yet decomposed
- St. Moritz — member areas not yet decomposed

## Coordinates

Coordinate policy for this pass-data stage:

- Prefer official resort or official pass-destination coordinates.
- For Ikon expansion, most coordinates come from official Ikon CMS `latlng` fields or official Ikon sub-destination records.
- Existing first-batch coordinates for Vail, Breckenridge, Park City Mountain, Mammoth, Aspen Snowmass members, Palisades Tahoe members, Deer Valley, Steamboat, Jackson Hole, and Big Sky were replaced or preserved according to the normalized generation pass where official Ikon CMS records were available.
- Some sub-destination/member rows have blank coordinates because official Ikon CMS records did not expose usable lat/lng. Those rows remain useful for access normalization but should be enriched before weather comparisons depend on them.

Future schema note: a single `latitude`/`longitude` per resort is a simplification. For weather and snow-quality decisions, the app will likely need base, mid-mountain, summit, and/or provider grid-point coordinates.

## Epic Pass 2026-2027 Expansion

Epic expansion research was completed after the Ikon pass expansion. Official Epic sources used:

- Epic regions overview: https://www.epicpass.com/regions.aspx
- Epic pass-results / resort listing page: https://www.epicpass.com/pass-results/lift-ticket-promotion.aspx
- Epic partner resorts page: https://www.epicpass.com/regions/partner-resorts.aspx
- Epic Europe page: https://www.epicpass.com/regions/europe.aspx
- Epic Australia page: https://www.epicpass.com/regions/australia.aspx
- Epic Telluride page: https://www.epicpass.com/regions/us/rockies/telluride.aspx
- Epic Resorts of the Canadian Rockies page: https://www.epicpass.com/regions/canada/rcr.aspx
- Epic Hakuba Valley page: https://www.epicpass.com/regions/japan/hakuba-valley.aspx
- Epic Rusutsu Resort page: https://www.epicpass.com/regions/japan/rusutsu-resort.aspx
- Epic restricted peak dates page: https://www.epicpass.com/info/peak-restricted-dates.aspx

### Epic owned/operated unlimited-access rows

The CSV now models full `Epic Pass, 2026-2027` unlimited access for the Vail Resorts owned/operated destinations listed on official Epic pages. The official Epic partner FAQ text identifies the North American owned/operated set as:

- Colorado / Rockies: Vail, Beaver Creek, Breckenridge, Keystone, Crested Butte
- Utah: Park City
- Tahoe / West: Heavenly, Northstar, Kirkwood
- Washington: Stevens Pass
- Canada: Whistler Blackcomb
- Northeast: Stowe, Okemo, Mount Snow, Hunter Mountain, Attitash, Wildcat, Mount Sunapee, Crotched Mountain
- Mid-Atlantic: Liberty, Roundtop, Whitetail, Jack Frost, Big Boulder, Seven Springs, Hidden Valley PA, Laurel Mountain
- Midwest: Wilmot, Afton Alps, Mt Brighton, Alpine Valley OH, Boston Mills, Brandywine, Mad River Mountain, Hidden Valley MO, Snow Creek, Paoli Peaks

The official Epic Australia page states full Epic Pass holders have unlimited and unrestricted access to Perisher, Falls Creek, and Hotham in the Southern Hemisphere winter season following the Northern Hemisphere winter season for which the pass is valid. For `2026-2027`, the CSV note records that this means the 2027 Southern Hemisphere season.

The official Epic Europe page states full Epic Pass provides unlimited access to Andermatt-Sedrun-Disentis and Crans-Montana in Switzerland.

`Whistler Blackcomb` is modeled as a resort group with physical member rows for Whistler Mountain and Blackcomb Mountain to preserve weather-comparison flexibility.

### Epic partner limited-access rows

The CSV now models the clearest full-Epic-pass partner rules as follows:

- Telluride — 7 days, no reservations required, physical Epic Pass card needed for direct-to-lift access.
- Resorts of the Canadian Rockies — 7 total days across Fernie Alpine Resort, Kicking Horse Mountain Resort, Kimberley Alpine Resort, Nakiska Ski Area, Mont-Sainte-Anne, and Stoneham Mountain Resort; no lodging requirement; physical pass direct-to-lift access.
- Hakuba Valley — 5 consecutive days with no restricted dates across the 10 Hakuba Valley resorts listed by Epic.
- Rusutsu Resort — 5 unrestricted consecutive days with no restricted peak dates.
- Verbier 4 Vallées — 5 consecutive days of unrestricted access.
- Les 3 Vallées — 7 consecutive days.
- Skirama Dolomiti — 7 consecutive days.
- Zillertal — 5 consecutive days; source notes 2026/27 expansion beyond Mayrhofen/Hintertux to neighboring Zillertal resorts.
- Saalbach & Zell am See-Kaprun — 5 days across Skicircus Saalbach Hinterglemm Leogang Fieberbrunn and Kitzsteinhorn/Zell am See-Kaprun.
- Silvretta Montafon — 5 consecutive days.
- Ski Arlberg — 3 consecutive days, with a lodging requirement booked directly through participating lodging partners.
- Sölden — 5 days.

Partner rows are generally modeled with `blackout_dates_apply=false` for full Epic Pass because the source language describes unrestricted/no restricted-date access where explicit. Where the constraint is lodging, physical card, mobile-pass limitation, ticket-window redemption, or consecutive-day use, it is captured in `notes` rather than the blackout boolean.

### Epic group/member modeling caveats

The Epic partner network has several shared-access products where access days should not be duplicated onto member resorts. Therefore, the following are targetable `resort_group_name` rows in `pass_resort_accesses.csv`:

- Whistler Blackcomb
- Resorts of the Canadian Rockies
- Hakuba Valley
- Verbier 4 Vallées
- Les 3 Vallées
- Skirama Dolomiti
- Zillertal
- Saalbach & Zell am See-Kaprun
- Ski Arlberg

For European partner groups, member rows are practical decompositions from official Epic descriptions and well-known resort-domain structures, but should be rechecked before production use because exact redemption boundaries, lodging requirements, rail add-ons, ticket-window requirements, and consecutive-day rules can change.


## First-Batch Resort-Specific Source URLs Preserved From Remote Main

The concurrent remote `main` documentation contained detailed first-batch resort-specific sources. They are preserved here as supplemental source references for the initial batch rows:

- Mammoth Mountain Ikon Pass page: https://www.mammothmountain.com/plan-your-trip/season-passes/ikon-pass
- Palisades Tahoe Ikon Pass page: https://www.palisadestahoe.com/plan-your-visit/lift-tickets-season-pass/ikon-pass
- Deer Valley Ikon / season pass pages:
  - https://www.deervalley.com/plan-your-trip/tickets-and-passes/ikon-pass
  - https://www.deervalley.com/plan-your-trip/tickets-and-passes/unlimited-pass
- Steamboat Ikon Pass page: https://www.steamboat.com/plan-your-trip/lift-tickets-ski-pass/ikon-pass
- Jackson Hole Ikon Pass page: https://www.jacksonhole.com/ikon-pass
- Big Sky Ikon Pass page: https://www.bigskyresort.com/ikon-pass
- Aspen Snowmass Ikon page: https://www.aspensnowmass.com/partner-passes/ikon-pass
- Ikon Aspen Snowmass destination page: https://www.ikonpass.com/en/destinations/aspen-snowmass/
- Epic regions page: https://www.epicpass.com/regions.aspx
- Epic pass-results / eligible passes page: https://www.epicpass.com/pass-results/lift-ticket-promotion.aspx
- Epic restricted peak dates page: https://www.epicpass.com/info/peak-restricted-dates.aspx
- Vail: https://www.vail.com/
- Breckenridge: https://www.breckenridge.com/
- Park City Mountain: https://www.parkcitymountain.com/

Remote-main coordinate caveat preserved: early first-batch coordinates were intended for weather/snow aggregation, not legal-boundary precision. A future `resort_locations` or `weather_stations` model should support base, mid-mountain, summit, and provider grid-point coordinates.

## Current Completion Status

As of this update, the CSVs contain expanded source-checked seed rows for both requested pass products:

- `Ikon Pass, 2026-2027`
- `Epic Pass, 2026-2027`

Validation performed:

- Every `pass_resort_accesses.csv` row has exactly one target (`resort_name` or `resort_group_name`).
- Every `resort_name` access target exists in `data/resorts.csv`.
- Every `resort_group_name` access target exists in `data/resort_groups.csv`.
- Every `resort_group_memberships.csv` row references an existing group and resort.
- Unlimited access rows have blank `access_days`.
- Limited access rows use integer `access_days`.
- Boolean fields use `true`/`false`.
- Every pass access row has a source URL.

## Remaining Data-Quality Caveats

1. Coordinates for many newly added Epic and international member resorts are approximate base-area or resort/town coordinates from official resort pages and reliable public map/geocoding references. They should be refined before weather-provider production use.
2. Some large European groups can be further decomposed in a later pass if the app needs highly granular weather comparisons across every valley, sector, or village lift domain.
3. This data models pass access only; it intentionally does not infer ownership beyond what official Epic/Ikon pages state.
4. This data models the full Epic Pass and full Ikon Pass only. Local, base, day, military, adaptive, youth, and regional pass products need separate product rows if the app later supports them.
