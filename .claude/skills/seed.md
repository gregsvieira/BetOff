---
description: Seed the local database with BetOff test data
---

Populate the local Supabase database with realistic test data for BetOff development.

## What to seed

- **5 test users** — one at each stimulus level (1–5), with appropriate `taper_started_at` values:
  - Level 5: `taper_started_at = now()` (new user)
  - Level 4: `taper_started_at = now() - interval '10 days'`
  - Level 3: `taper_started_at = now() - interval '30 days'`
  - Level 2: `taper_started_at = now() - interval '90 days'`
  - Level 1: `taper_started_at = now() - interval '150 days'`
  - All start with `virtual_balance = 1000`.

- **Mock sports matches** (static JSON at `src/data/mock-matches.json` if the Odds API is not yet integrated):
  - 5–10 upcoming matches across 2–3 sports (football, basketball, tennis).
  - Include team names, start times (some in the next 30 min, some tomorrow), and simple decimal odds.

- **Sample bets** for each test user — a mix of `pending` and `resolved` bets across game types.

- **Sample sessions** with `reflection_text` filled in.

- **Sample forum posts** (3–5) with 1–2 replies each, covering realistic recovery topics.

- **Sample milestones** for users at lower stimulus levels.

## Steps

1. Check whether `supabase/seed.sql` exists. If it does, review it before overwriting.

2. Write or update `supabase/seed.sql` with `INSERT` statements for the data above. Use `ON CONFLICT DO NOTHING` so the seed is safe to re-run.

3. Apply the seed: `supabase db reset` (resets and re-runs all migrations + seed) OR `psql $(supabase db url) -f supabase/seed.sql` to apply without resetting.

4. Confirm the data is present by querying: `SELECT id, display_name, stimulus_level FROM public.users;`

5. Report the seeded record counts.
