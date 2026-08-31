---
description: Create and apply a new Supabase database migration
---

Create a new Supabase migration for BetOff and apply it to the local database.

## Steps

1. Ask the user for the migration name if not provided (e.g. "add_stimulus_level_to_users"). Convert it to snake_case.

2. Create the migration file:
   ```
   supabase migration new <name>
   ```
   This creates `supabase/migrations/<timestamp>_<name>.sql`.

3. Open the new `.sql` file and write the migration SQL based on the user's intent. Follow these conventions:
   - Use `IF NOT EXISTS` / `IF EXISTS` guards so migrations are safe to re-run during development.
   - Add RLS policies immediately after creating any table (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY`).
   - Reference the `users` table as `public.users`, not `auth.users` directly — use FK to `auth.users(id)` only on the `id` column.
   - Enums go in `public` schema: `CREATE TYPE public.game_type AS ENUM (...)`.

4. Apply the migration to the local database:
   ```
   supabase db push
   ```
   If there are errors, show them and offer to fix the SQL.

5. Regenerate TypeScript types after a successful migration (run the `types` skill or `supabase gen types typescript --local > src/types/database.ts`).
