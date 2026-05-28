# Ski Resort App — Project Context

## Overview

The project is a Ruby on Rails web app that aggregates ski resorts available on major ski pass products, beginning with Ikon Pass and Epic Pass. The app should later support additional pass products and independent resorts.

The core user need is to compare where snow and weather conditions are best across ski resorts, especially when deciding where to visit.

## Core User Story

As a skier or snowboarder, I want to see current and forecast conditions across resorts included in my pass, so that I can choose the best mountain to visit based on snow, weather, and precipitation outlook.

## Initial Pass Products

- Ikon Pass
- Epic Pass

Future products may include other pass programs or independent mountains with no pass affiliation.

## Weather Provider

The intended weather API provider is Pirate Weather.

The app should use Pirate Weather to provide:

- current weather conditions
- forecast temperature
- forecast precipitation
- forecast snowfall where available or derivable
- aggregate forecast snowfall for the next 7 days

## Core Resort Metrics

For each mountain/resort, the app should eventually show:

- current temperature
- current precipitation
- forecast temperature
- forecast precipitation
- snow depth at the main lodge/base area
- aggregate forecast snowfall over the next 7 days

## Important Product/Domain Distinctions

### Resort vs. Resort Group

Some pass websites market grouped destinations rather than individual ski areas. Examples include:

- SkiBig3
- Hakuba Valley
- Dolomiti Superski
- Les 3 Vallées
- Grandvalira Resorts Andorra

The app should preserve both concepts where useful:

- `ResortGroup`: marketed or regional grouping
- `Resort`: individual ski area/mountain where weather coordinates and conditions are tracked

### Pass Access vs. Ownership

A resort appearing on a pass does not necessarily mean the pass company owns the resort. The app should model pass access separately from ownership.

This matters because pass access can vary by:

- pass product tier
- blackout dates
- number of days available
- partner terms
- reservation requirements
- lodging requirements
- season/year

## Preliminary Data Model Direction

Potential tables/models:

- `pass_products`
- `resorts`
- `resort_groups`
- `resort_group_memberships`
- `pass_resort_accesses`
- `weather_snapshots`
- `forecasts`

Possible relationship shape:

```text
PassProduct has_many PassResortAccesses
PassProduct has_many Resorts through PassResortAccesses

Resort has_many PassResortAccesses
Resort has_many PassProducts through PassResortAccesses

ResortGroup has_many ResortGroupMemberships
ResortGroup has_many Resorts through ResortGroupMemberships
```

## Initial Architecture Preference

Start with a conventional Rails application:

- PostgreSQL database
- Rails models and migrations
- server-rendered views
- Hotwire/Turbo for interactivity where useful
- background jobs later for weather refreshes
- cached weather responses to avoid slow page loads and unnecessary API calls

Avoid a separate JavaScript SPA unless the product later requires richer client-side behavior.

## Security and Reliability Notes

- Do not commit Pirate Weather API keys.
- Store secrets in environment variables, Rails credentials, or Codespaces secrets.
- Cache external API responses.
- Handle API failures gracefully.
- Avoid making live API calls from every page render.
- Add rate limiting or refresh intervals if needed.

## Development Style

The user wants to learn through the process. Assistance should be Socratic:

- explain why Rails conventions are used
- ask short conceptual questions at decision points
- still provide direct answers and working code
- keep code intermediate-level, robust, and secure

## Current Repository

GitHub repository:

```text
https://github.com/hast-zing-psec-rhon/ski_resort_app.git
```

Local development originally began at:

```text
/Users/mv/Documents/Ski Resort App
```

The project is expected to move into GitHub Codespaces, with this documentation serving as durable context for future Codex sessions.
