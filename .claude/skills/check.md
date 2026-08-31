---
description: Run TypeScript type-check, ESLint, and Next.js build verification
---

Run all static checks for the BetOff codebase and report results clearly.

## Steps

1. **Type check** — run `npx tsc --noEmit`. Capture all errors. Do not proceed to the next step on failure — report the errors and offer to fix them.

2. **Lint** — run `next lint` (or `npx eslint src --ext ts,tsx`). Capture warnings and errors separately. Errors are blocking; warnings are informational.

3. **Build check** — run `next build`. This catches import errors and missing environment variables that type-check misses.

4. **Report** — summarize the result as a concise table:
   | Check | Status | Issues |
   |-------|--------|--------|
   | TypeScript | ✓ / ✗ | N errors |
   | ESLint | ✓ / ✗ | N errors, N warnings |
   | Build | ✓ / ✗ | — |

   If any check failed, list the specific errors below the table grouped by file.

5. If everything passes, confirm the branch is clean and ask if the user wants to commit.
