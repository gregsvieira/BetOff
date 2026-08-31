---
description: Regenerate TypeScript types from the local Supabase schema
---

Regenerate `src/types/database.ts` from the current local Supabase schema.

## Steps

1. Confirm that Supabase local services are running (`supabase status`). If not, tell the user to run `/dev` first.

2. Run:
   ```
   supabase gen types typescript --local > src/types/database.ts
   ```

3. Read the generated file and verify it contains the expected tables: `users`, `bets`, `sessions`, `forum_posts`, `forum_replies`, `transactions`, `milestones`. If any are missing, it likely means the corresponding migration has not been applied — report which tables are absent.

4. Check that the `stimulus_level` column exists on the `users` type and that the `game_type` enum includes `sports`, `slots`, `roulette`. These are BetOff-critical fields.

5. Run a quick type check (`tsc --noEmit`) to confirm the new types don't break existing imports.

6. Report the result: which types were added/changed, and whether the type check passed.
