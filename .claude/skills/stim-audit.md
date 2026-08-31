---
description: Audit all game components for correct StimLevelContext usage
---

The Stimulus Taper System requires that every game component and design token reads the user's `stimulus_level` from a single source: the `StimLevelContext` React context (via `useStimLevel()`) and the `data-stim` CSS attribute on `<html>`. No component should hard-code level checks or directly read `stimulus_level` from Supabase inside game components.

This audit verifies that rule is upheld.

## Steps

1. **Find all game components** — search `src/components/games/` and `src/app/(games)/` for `.tsx` files.

2. **Check for forbidden patterns** in each file. Report any file that contains:
   - `stimulus_level` read directly from a Supabase query inside a component (instead of from context)
   - Hard-coded level comparisons like `if (level === 5)` or `level >= 3` outside of `StimLevelContext` or the `useStimLevel` hook
   - Hard-coded color strings (`#C9A03E`, `#B03030`, etc.) instead of CSS custom properties or Tailwind `data-stim` variants
   - Sound or animation logic not gated by the value from `useStimLevel()`

3. **Check the context provider** — verify that `StimLevelProvider` in `src/context/StimLevelContext.tsx` (or equivalent path):
   - Sets `document.documentElement.dataset.stim = stimLevel` on mount and on change.
   - Exposes a `useStimLevel()` hook that returns the current level.
   - Is placed in the root layout above all game routes.

4. **Check Tailwind config** — verify that `tailwind.config.ts` includes `data-stim` as a variant or that a CSS file defines `[data-stim="5"]` selectors for the Level 5 palette.

5. **Report** — list each violation with file path and line number. If no violations, confirm the audit passed. Offer to fix any violations found.
