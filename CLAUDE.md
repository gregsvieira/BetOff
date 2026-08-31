# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BetOff is a non-profit harm-reduction web platform that substitutes real-money gambling with a low-stimulus simulation, helping self-aware addicts quit by breaking dopamine loops.

- **Stack**: Next.js 14 (App Router) + TypeScript + Tailwind CSS + Supabase (PostgreSQL, Auth, Edge Functions) + Vercel
- **Stage**: Spec & design complete — no application code yet

## Key Documents

Read these before working on any feature:

- [`docs/context.md`](docs/context.md) — Mission, target persona, and the four non-negotiable core principles
- [`docs/plan.md`](docs/plan.md) — Data model, feature phases, and technical decisions
- [`docs/design-system.md`](docs/design-system.md) — Color tokens, motion policy, and component guidelines

## Commands

```bash
pnpm dev          # Start Next.js dev server (http://localhost:3000)
pnpm build        # Production build
pnpm lint         # ESLint
pnpm tsc --noEmit # TypeScript check

pnpm supabase start   # Start local Supabase (Docker required)
pnpm supabase stop    # Stop local Supabase
pnpm supabase status  # Show local URLs and keys
pnpm supabase db push # Apply pending migrations
pnpm supabase gen types typescript --local > src/types/database.ts
```

**Package manager:** pnpm. Never use npm or yarn in this project.

## Skills

| Skill | Purpose |
|-------|---------|
| `/dev` | Start Supabase local + Next.js dev server, verify `.env.local` |
| `/check` | TypeScript + ESLint + Next.js build — full static verification |
| `/migrate` | Create and apply a new Supabase migration with BetOff conventions |
| `/types` | Regenerate `src/types/database.ts` from local Supabase schema |
| `/seed` | Seed DB with test users (one per stimulus level), matches, bets, forum posts |
| `/stim-audit` | Verify all game components read from `StimLevelContext`, not hard-coded values |
| `/new-game` | Scaffold a stimulus-level-aware game component + page route |

## Core Constraints (never violate)

1. No real money — virtual coins only, ever
2. Mandatory reflection prompt at end of every session — not skippable at any level
3. The **Stimulus Taper** is the central design pattern — every game component, color token, sound, and animation is driven by the user's `stimulus_level` (1–5). Level 5 is fully stimulating (day 0); Level 1 is calm (day 121+). Never hard-code a level check in a component — read from `StimLevelContext` / `data-stim` attribute.
4. Recovery stimulus (milestones, streaks, community) grows as gambling stimulus decreases — users always have a rewarding reason to return
