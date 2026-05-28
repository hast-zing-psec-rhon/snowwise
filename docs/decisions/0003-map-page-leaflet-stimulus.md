# ADR 0003: Map Page Uses Leaflet With Stimulus

## Status

Accepted

## Context

Snowwise needs a dedicated map page that lets skiers compare resorts by geography, pass access, and snow/weather quality. The application is server-rendered Rails with importmap and Stimulus, and no paid map provider token is configured.

## Decision

Implement the first map experience as a standalone `/map` page:

- Rails routes `/map` to `MapsController#show`.
- Rails renders resort marker JSON from `ResortMapMarker` presenter objects.
- The presenter uses existing resort coordinates, pass access, snow observations, weather forecasts, and `Conditions::ScoreCalculator`.
- Leaflet renders OpenStreetMap tiles without requiring private API keys.
- A Stimulus controller owns marker rendering, filters, selected-resort state, and visible-resort insights.

## Consequences

- The root conditions page remains focused on resort list comparison.
- The map page can run locally without credentials, though Leaflet assets and map tiles currently load from public CDNs.
- Client-side filtering is simple and appropriate for the current dataset; backend map filtering may be needed if resort volume grows significantly.
