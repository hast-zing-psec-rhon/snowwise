# Initial Pass Resort Research

This document captures an initial source-checked resort list for Ikon Pass and Epic Pass. It is intended as research context, not yet canonical seed data.

Important: pass access rules change by season, pass tier, partner terms, blackout dates, lodging requirements, and reservation rules. Before production use, validate against official current pass pages and model access terms explicitly.

## Sources Consulted

- Ikon Pass destinations page: https://www.ikonpass.com/en/destinations
- Ikon Pass FAQ / destination community references: https://www.ikonpass.com/en/faq
- Epic Pass regions page: https://www.epicpass.com/regions.aspx
- Epic Pass Canada page: https://www.epicpass.com/regions/canada.aspx
- Epic Pass Europe page: https://www.epicpass.com/regions/europe.aspx
- Epic Pass Japan page: https://www.epicpass.com/regions/japan.aspx
- Epic Pass partner resorts page: https://www.epicpass.com/regions/partner-resorts.aspx

## Ikon Pass — Initial Resort/Destination List

### United States

#### Alaska

- Alyeska Resort

#### California

- Palisades Tahoe
- Sierra-at-Tahoe
- Mammoth Mountain
- June Mountain
- Big Bear Mountain Resort
  - Bear Mountain
  - Snow Summit
- Snow Valley

#### Colorado

- Aspen Snowmass
- Steamboat
- Winter Park Resort
- Copper Mountain
- Arapahoe Basin
- Eldora Mountain Resort

#### Idaho

- Sun Valley
- Schweitzer

#### Maine

- Sugarloaf
- Sunday River

#### Michigan

- Boyne Mountain
- The Highlands

#### Montana

- Big Sky Resort

#### New Hampshire

- Loon Mountain

#### New Mexico

- Taos Ski Valley

#### Oregon

- Mt. Bachelor

#### Pennsylvania

- Camelback Resort
- Blue Mountain Resort

#### Utah

- Deer Valley Resort
- Solitude Mountain Resort
- Alta Ski Area
- Snowbird
- Brighton
- Snowbasin

#### Vermont

- Stratton
- Sugarbush Resort
- Killington - Pico
  - Killington
  - Pico Mountain

#### Washington

- Crystal Mountain
- The Summit at Snoqualmie

#### West Virginia

- Snowshoe Mountain

#### Wyoming

- Jackson Hole Mountain Resort

### Canada

#### Alberta

- SkiBig3
  - Banff Sunshine
  - Lake Louise Ski Resort
  - Mt. Norquay

#### British Columbia

- Revelstoke Mountain Resort
- Cypress Mountain
- RED Mountain
- Panorama
- Sun Peaks Resort

#### Ontario

- Blue Mountain

#### Québec

- Tremblant
- Le Massif de Charlevoix

### South America

#### Chile

- Valle Nevado

### Europe

#### Andorra

- Grandvalira Resorts Andorra

#### Austria

- Kitzbühel
- Ischgl

#### France

- Chamonix Mont-Blanc Valley

#### Italy

- Dolomiti Superski

#### Switzerland

- Zermatt Matterhorn
- St. Moritz

### Oceania

#### Australia

- Thredbo
- Mt Buller

#### New Zealand

- Coronet Peak
- The Remarkables
- Mt Hutt

### Asia

#### Japan

- Niseko United
- Arai Mountain Resort

## Epic Pass — Initial Resort/Destination List

### United States

#### Colorado / Rockies

- Vail
- Beaver Creek
- Breckenridge
- Keystone
- Crested Butte
- Telluride — partner access

#### Utah

- Park City

#### California / Nevada / West

- Heavenly
- Northstar
- Kirkwood

#### Washington

- Stevens Pass

#### Vermont / Northeast

- Stowe
- Okemo
- Mount Snow

#### New Hampshire / Northeast

- Attitash
- Wildcat
- Mount Sunapee
- Crotched Mountain

#### New York / Northeast

- Hunter Mountain

#### Pennsylvania / Mid-Atlantic

- Seven Springs
- Laurel Mountain
- Liberty Mountain
- Hidden Valley PA
- Jack Frost
- Big Boulder
- Roundtop Mountain
- Whitetail Resort

#### Minnesota / Midwest

- Afton Alps

#### Michigan / Midwest

- Mt. Brighton

#### Ohio / Midwest

- Mad River Mountain
- Alpine Valley Ohio
- Boston Mills
- Brandywine

#### Wisconsin / Midwest

- Wilmot Mountain

#### Missouri / Midwest

- Snow Creek
- Hidden Valley Missouri

#### Indiana / Midwest

- Paoli Peaks

### Canada

#### British Columbia

- Whistler Blackcomb
- Fernie Alpine Resort — partner
- Kicking Horse Mountain Resort — partner
- Kimberley Alpine Resort — partner

#### Alberta

- Nakiska Ski Area — partner

#### Québec

- Mont-Sainte-Anne — partner
- Stoneham — partner

### Australia

- Perisher
- Falls Creek
- Mount Hotham

### Japan

- Rusutsu Resort
- Hakuba Valley, including:
  - Jigatake Snow Resort
  - Kashimayari Snow Resort
  - White Resort Hakuba Sanosaka
  - ABLE Hakuba Goryu Snow Resort
  - Hakuba 47 Winter Sports Park
  - Hakuba Happo-one Snow Resort
  - Hakuba Iwatake Snow Field
  - Tsugaike Mountain Resort
  - Hakuba Norikura Onsen Snow Resort
  - Hakuba Cortina Snow Resort

### Europe

#### Switzerland

- Andermatt-Sedrun-Disentis
- Crans-Montana Mountain Resort
- Verbier 4 Vallées — partner

#### Italy

- Skirama Dolomiti — partner

#### France

- Les 3 Vallées — partner

#### Austria

- Zillertal — partner
- Silvretta Montafon — partner
- Sölden — partner
- Saalbach & Zell am See-Kaprun — partner
  - Skicircus Saalbach Hinterglemm Leogang Fieberbrunn
  - Schmittenhöhe
  - Kitzsteinhorn
- Ski Arlberg — partner, lodging requirement applies

## Seed Data Implication

When converting this research into Rails seed data, avoid treating the marketed pass destination list as a flat list of identical records.

Recommended approach:

- Create pass products.
- Create resort groups for multi-mountain marketed regions.
- Create individual resorts where weather coordinates are meaningful.
- Link resorts to pass products through an access table.
- Add access metadata later, such as days included, blackout rules, reservation requirements, and partner status.
