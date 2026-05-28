# Resort image source data

## Scope

`data/resort_images.csv` provides one image-source row for every resort currently listed in `data/resorts.csv`. The file stores only source/provenance metadata and direct image URLs; no image binaries were downloaded or committed.

## Image source policy

Selection followed the repository policy for official/real resort imagery:

1. Prefer a direct official resort logo URL when a stable logo could be identified on the official resort/operator page.
2. If a logo was not available, use a real mountain/resort photo from an official resort, resort operator, pass network, or authorized destination page.
3. Do not use Google Images, Pinterest, Reddit, private blogs, unlicensed social media reposts, or unclear third-party image reposts.
4. Leave `image_url` blank and mark `image_type` as `unavailable` when a stable acceptable direct image URL was not found.

## Source priority used

1. Official resort website URL from `data/resorts.csv`.
2. Official resort-operator websites when the resort row represents a marketed destination or member mountain (for example, Dolomiti Superski, Les 3 Vallées, Skirama Dolomiti, Shiga Kogen, Hakuba Valley, Niseko United, Vail Resorts/Epic Pass regional pages).
3. Official pass-network destination pages where resort homepages were inaccessible to static automated research or returned maintenance/bot-protection pages.
4. No general third-party image search results were used as final image sources.

## Notable source choices and caveats

- Several Vail Resorts-owned resort homepages returned non-content maintenance/bot-response HTML during automated research. For those rows, official Epic Pass regional destination-card photos from `epicpass.com`/`scene7.vailresorts.com` were used as authorized operator/pass-network imagery.
- Several physical mountains that are marketed as a shared destination use a shared official logo or shared official pass-network image. Examples include Whistler/Blackcomb, Dolomiti Superski member regions, Hakuba Valley member resorts, Shiga Kogen ski areas, Niseko United member areas, Skirama Dolomiti member areas, and Les 3 Vallées member resorts.
- Some extracted official logos are favicons, header logos, footer logos, or brand marks discovered in official page HTML/structured data. They are suitable as provenance-backed source URLs, but future UI polish may prefer higher-resolution media-kit assets where available.
- Direct image URLs remain subject to the source site’s terms, hotlinking policy, robots policy, and CDN stability. This dataset records provenance; it does not grant independent redistribution rights. Before production display, review source terms and consider storing licensed/approved assets through the app’s own asset pipeline or CDN.

## Resorts without acceptable direct image URL found

The following rows are intentionally marked `unavailable` because the automated/static research pass did not identify a stable direct image URL from an acceptable official or authorized source:

- Alyeska Resort
- Andermatt-Sedrun-Disentis
- Arai Mountain Resort
- Crans-Montana
- Crystal Mountain Resort
- Snowshoe Mountain
- Steamboat
- Stratton
- Taos Ski Valley
- Tremblant
- Yunding Snow Park

These should be revisited manually via official media kits, press rooms, structured media APIs, or official pass-network pages before production launch.

## Validation summary

A validation command was run after generation to check that:

- every `resort_name` exactly matches a name in `data/resorts.csv`;
- every resort in `data/resorts.csv` is represented exactly once;
- there are no duplicate `resort_name` rows;
- `image_type` is one of `logo`, `mountain_photo`, or `unavailable`;
- `image_url` and `image_source_url` are present for all available rows and blank only for unavailable rows;
- `source_notes` is present for every row.

Current row counts:

- Total resorts covered: 215
- `logo`: 164
- `mountain_photo`: 40
- `unavailable`: 11
