# dbt-gameflow

A  gaming analytics platform built on DuckDB + dbt, combining real Steam game data (122k games from Kaggle) with synthetic player behavior data (740k rows) to simulate a  gaming company's data warehouse.

## What this project demonstrates

- **Hybrid data architecture** — real Kaggle dataset + synthetically generated behavioral data
- **Full dbt medallion layers** — staging → intermediate → marts with clear grain definitions
- **Window functions** — RANK, ROW_NUMBER, LAG, SUM/AVG with PARTITION BY and ROWS BETWEEN frames
- **Slowly Changing Dimensions** — SCD Type 2 via dbt snapshots
- **Data quality** — 29 tests covering primary keys, foreign keys, and accepted values
- **Reusable macros** — safe_divide, clean_string, generate_surrogate_key, is_valid_email
- **Seeds** — genre metadata, region metadata, subscription tier reference data
- **dbt docs** — full lineage DAG from raw sources to mart models
- **Polars integration** — LazyFrame post-processing on top of DuckDB

## Data sources

| Source | Type | Rows | Description |
|--------|------|------|-------------|
| Steam Games (Kaggle) | Real | 122,611 | Game catalog with prices, ratings, genres |
| Players | Synthetic | 10,000 | Player profiles with subscription tiers and churn data |
| Sessions | Synthetic | 200,000 | Gaming sessions referencing real Steam AppIDs |
| Purchases | Synthetic | 30,000 | Transactions with item types and refund flags |
| Events | Synthetic | 500,000 | Granular player actions — logins, levels, achievements |

## Project structure

```
models/
├── staging/          # One view per source, type fixes, PII removal
│   ├── stg_players.sql
│   ├── stg_steam_games.sql
│   ├── stg_sessions.sql
│   ├── stg_purchases.sql
│   └── stg_events.sql
├── intermediate/     # Ephemeral joins and aggregations
│   ├── int_player_activity.sql
│   ├── int_game_metrics.sql
│   └── int_session_enriched.sql
└── marts/            # Business-ready tables
    ├── fct_player_summary.sql
    ├── fct_game_performance.sql
    ├── fct_revenue.sql
    ├── fct_session_analytics.sql
    └── fct_churn_signals.sql
macros/
├── safe_divide.sql
├── clean_string.sql
├── cents_to_usd.sql
├── is_valid_email.sql
└── generate_surrogate_key.sql
seeds/
├── genre_metadata.csv
├── region_metadata.csv
└── subscription_tiers.csv
```

## Mart models

| Model | Grain | Key features |
|-------|-------|-------------|
| `fct_player_summary` | One row per player | Player segments, churn risk scores, playtime per session |
| `fct_game_performance` | One row per game | Revenue rank, popularity rank, genre rank via RANK() |
| `fct_revenue` | One row per purchase | Cumulative spend, purchase sequence, days between purchases via LAG() |
| `fct_session_analytics` | One row per session | Rolling 7-session avg, cumulative playtime, session gaps via LAG() |
| `fct_churn_signals` | One row per at-risk player | 6,953 players flagged for churn intervention |
****
