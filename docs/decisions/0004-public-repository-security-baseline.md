# 0004 Public repository security baseline

## Status

Accepted

## Context

Snowwise is being prepared for publication in a public GitHub repository. Public hosting changes the threat model: source code, configuration defaults, deployment manifests, and historical development files may be inspected by anyone. The app currently has no user accounts or write-facing public controllers, but it does call external weather/snow providers from background tasks and will run as an internet-facing Rails application.

## Decision

Before publishing the repository publicly, we will use the following baseline controls:

- Keep secrets out of Git and require provider keys through environment variables or Rails credentials.
- Remove local Codex workspace state from tracked files.
- Keep CSRF protection enabled in production via `ApplicationController`.
- Scope beginner AppDev security relaxations to development/test only.
- Use direct first-party API endpoints for OpenAI and Pirate Weather rather than third-party proxy URLs.
- Avoid logging upstream OpenAI response bodies on extraction failures.
- Add baseline browser security headers and a conservative Content Security Policy.
- Enable host authorization in production, with Render's default Snowwise host plus `ALLOWED_HOSTS` for custom domains.
- Add SSRF-oriented validation for snow report fetches by requiring HTTP(S), rejecting URL credentials, rejecting private-network host resolution, limiting redirects, and truncating stored raw response bodies.
- Rename Render blueprint resources to Snowwise-specific names and require non-synced provider API keys.

## Consequences

These controls make the repository materially safer for public visibility and internet deployment without adding authentication or heavyweight security infrastructure before the product needs it.

Trade-offs:

- Host authorization requires deployment operators to maintain `ALLOWED_HOSTS` for custom domains.
- The CSP allows external Leaflet assets and OpenStreetMap tiles for the current map implementation; self-hosting those assets would permit a stricter policy later.
- Snow report fetching still relies on external resort pages. Redirect validation is best-effort and should be revisited before allowing user-submitted source URLs.
- The encrypted `config/credentials.yml.enc` remains tracked, which is conventional for Rails, but any existing production keys should be rotated if the corresponding master key was ever exposed.
