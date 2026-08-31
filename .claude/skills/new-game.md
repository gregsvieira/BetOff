---
description: Scaffold a new stimulus-level-aware game component for BetOff
---

Create a new game component that correctly integrates with BetOff's Stimulus Taper System.

## Steps

1. Ask the user for:
   - Game name (e.g. "Dice", "Blackjack")
   - Game type enum value (must be one of `sports | slots | roulette` or a new value to add via migration)

2. If a new `game_type` enum value is needed, remind the user to create a migration first (`/migrate`) before proceeding.

3. Create the component at `src/components/games/<GameName>Game.tsx`. The component must:

   ```tsx
   'use client'

   import { useStimLevel } from '@/context/StimLevelContext'

   export function <GameName>Game() {
     const stimLevel = useStimLevel()

     // Animation: only render motion elements when stimLevel >= 3
     // Sound: only trigger audio when stimLevel >= 3
     // Colors: use CSS custom properties / data-stim Tailwind variants, NOT inline styles keyed on stimLevel
     // Result delay: compute resolves_at on the SERVER based on stimLevel at bet placement — do not derive it here

     return (
       // ... game UI
     )
   }
   ```

   Key rules enforced in the scaffold:
   - Never import `createClient` inside a game component for the purpose of reading `stimulus_level` — use `useStimLevel()`.
   - Animation and sound effects are conditionally rendered based on `stimLevel`, but colors come from CSS (`data-stim` attribute on `<html>`).
   - The component does NOT compute `resolves_at` — that is always done server-side at bet placement.

4. Create the page route at `src/app/(games)/<game-name>/page.tsx` that wraps the component and handles the session + reflection flow.

5. Add the game to the nav in `src/components/layout/Nav.tsx` (or equivalent).

6. Add a note to `docs/plan.md` under the relevant phase marking the game as scaffolded.

7. Run `/check` to confirm no TypeScript errors were introduced.
