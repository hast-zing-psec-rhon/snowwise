# Snowwise

Snowwise is a Ruby on Rails application for comparing ski resort conditions across pass products such as Ikon Pass and Epic Pass.

The app aggregates resort access, current mountain weather, base snow depth, recent snowfall, and forecast snowfall to help skiers and snowboarders decide where to ski.

## Security and secrets

- Do not commit API keys, Rails master keys, `.env` files, database URLs, or provider credentials.
- Production secrets should be supplied through the hosting provider or Rails credentials.
- Required production environment variables include `DATABASE_URL`, `SECRET_KEY_BASE`, and `PIRATE_WEATHER_API_KEY`.
- Optional snow-report extraction tasks use `OPENAI_API_KEY`, `OPENAI_MODEL`, and `OPENAI_REASONING_EFFORT`.
- Set `ALLOWED_HOSTS` to a comma-separated list of production hostnames when deploying outside the default Render blueprint.

All files are covered by the MIT license; see [LICENSE.txt](LICENSE.txt).
