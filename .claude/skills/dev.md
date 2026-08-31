---
description: Start the full local development stack (Supabase + Next.js)
---

Start the BetOff local development environment.

## Steps

1. Check that the Supabase CLI is installed (`supabase --version`). If missing, tell the user to install it: `brew install supabase/tap/supabase`.

2. Check if Supabase local services are already running (`supabase status`). If not, start them: `supabase start`. Wait for it to finish and capture the local API URL, anon key, and Studio URL.

3. Verify that a `.env.local` file exists at the project root with at minimum:
   ```
   NEXT_PUBLIC_SUPABASE_URL=
   NEXT_PUBLIC_SUPABASE_ANON_KEY=
   ```
   If it is missing or the values are empty, fill them in from `supabase status` output.

4. Start the Next.js dev server in the background: `npm run dev` (or `pnpm dev` / `bun dev`, whichever matches the project's package manager).

5. Report the URLs to the user:
   - App: http://localhost:3000
   - Supabase Studio: http://localhost:54323
   - Supabase API: (from `supabase status`)
