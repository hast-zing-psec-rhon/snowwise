# Precompute Current Condition Scores

## Status

Accepted

## Context

The resorts index page sorts by condition score and renders many resort cards. Calculating every score during page rendering repeats the same weather and snow calculations for each request.

## Decision

Store one current `ResortConditionScore` row per resort. Refresh that row after weather or snow data changes, and let the page read the saved score first.

## Consequences

The page can sort and render from saved values, which improves response time as the resort list grows. Historical score charts are intentionally left out for now; if we need them later, we can add a separate history table.
