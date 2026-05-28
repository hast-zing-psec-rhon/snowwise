# AGENTS.md

## Project

This repository is a Ruby on Rails web application for aggregating ski resort snow and weather conditions across ski pass products, initially Ikon Pass and Epic Pass, with flexibility to support other pass products and independent resorts.

## Product Goal

Help skiers and snowboarders compare current and forecast mountain conditions across resorts so they can decide where to ski.

The app should centralize resort access information, current weather, precipitation, snow depth, and forecast snowfall.

## Assistant Behavior

When assisting on this project:

- Use a Socratic teaching style.
- Give direct answers when the user asks direct questions.
- Also ask guiding questions that help the user understand Rails, data modeling, testing, security, and architecture.
- Explain trade-offs, not just implementation steps.
- Prefer clear intermediate-level Rails code: conventional, readable, secure, testable, and extensible without unnecessary abstraction.
- Avoid over-engineering early; make decisions that preserve future flexibility.

## Technical Direction

Default assumptions unless changed by an explicit decision:

- Framework: Ruby on Rails.
- Database: PostgreSQL.
- Frontend: Rails server-rendered views with Hotwire/Turbo/Stimulus initially.
- Weather provider: Pirate Weather API.
- Secrets: use Rails credentials or environment variables; never commit API keys.
- Testing: use the project-selected Rails test framework consistently.

## Modeling Principles

Do not hard-code Ikon or Epic logic directly into resorts.

Prefer flexible relationships:

- A resort can be associated with many pass products.
- A pass product can include many resorts.
- Some marketed destinations are resort groups rather than single mountains.
- Weather and snow data should be tied to specific resort/base-area coordinates where possible.

Likely core concepts:

- `PassProduct`
- `Resort`
- `ResortGroup`
- `ResortGroupMembership`
- `PassResortAccess`
- `WeatherSnapshot`
- `Forecast`

## Development Workflow

- Keep important project decisions in documentation, not only in chat.
- Use lightweight Architecture Decision Records under `docs/decisions/` when architectural choices are made.
- Commit meaningful milestones.
- Run relevant tests before commits when practical.
- Prefer small, reviewable changes.
