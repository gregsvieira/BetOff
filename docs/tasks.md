# BetOff — Task List

Check off each item as it is completed. Tasks are ordered for execution — dependencies flow top to bottom within each phase.

---

## Phase 0 — Spec & Design

- [x] Create `docs/context.md`
- [x] Create `docs/plan.md`
- [x] Create `docs/design-system.md`
- [x] Create `.claude/skills/` with project skills
- [x] Create `docs/tasks.md`

---

## Phase 1 — MVP

### 1.1 Project Bootstrap

- [x] Initialize Next.js 14 project with TypeScript and Tailwind CSS
- [x] Configure `tsconfig.json` path alias (`@/` → `src/`)
- [x] Initialize Supabase project locally (`supabase init`)
- [x] Create `.env.local` from `supabase status` credentials
- [x] Create `src/lib/supabase/client.ts` (browser client)
- [x] Create `src/lib/supabase/server.ts` (server client)
- [x] Create `src/middleware.ts` for Supabase session refresh
- [x] Install dependencies: `@supabase/ssr`, `lucide-react`

### 1.2 Database — Migrations

- [ ] Migration: `game_type` enum (`sports | slots | roulette`)
- [ ] Migration: `bet_outcome` enum (`win | loss | void`) and `bet_status` enum (`pending | resolved`)
- [ ] Migration: `public.users` table (id, display_name, virtual_balance, stimulus_level, taper_started_at, created_at)
- [ ] Migration: `public.bets` table (all columns + RLS)
- [ ] Migration: `public.sessions` table (all columns + RLS)
- [ ] Migration: `public.transactions` table (all columns + RLS)
- [ ] Migration: `public.milestones` table (all columns + RLS)
- [ ] Migration: `public.forum_posts` and `public.forum_replies` tables (all columns + RLS)
- [ ] Migration: trigger to auto-create `public.users` row on `auth.users` insert
- [ ] Generate TypeScript types (`/types`)
- [ ] Seed DB with test data (`/seed`)

### 1.3 Stimulus Taper System

- [ ] Create `src/lib/taper.ts` — `resolveDelay(stimLevel)` map and level schedule table
- [ ] Create `src/context/StimLevelContext.tsx` with `StimLevelProvider` and `useStimLevel()` hook
- [ ] In root layout: read `stimulus_level` from Supabase, pass to `StimLevelProvider`, set `data-stim` on `<html>`
- [ ] Configure Tailwind `data-stim` variants in `tailwind.config.ts` (colors, animation classes per level)
- [ ] Define per-level CSS custom properties in `globals.css` (color tokens from `docs/design-system.md`)
- [ ] Create Edge Function: `taper-advance` — daily cron that updates `stimulus_level` based on `days since taper_started_at`
- [ ] Run `/stim-audit` — confirm architecture is wired correctly before any game code

### 1.4 Auth

- [ ] Sign-up page (`/signup`) — email + password form, server action
- [ ] Login page (`/login`) — email + password + magic link option
- [ ] Middleware: protect `/sports`, `/casino`, `/forum`, `/profile`, `/dashboard` routes
- [ ] Logout server action + button in header
- [ ] Post-signup redirect to `/sports` (first experience)

### 1.5 Layout & Navigation

- [ ] Root layout with header, main, footer
- [ ] Header: virtual balance display, `TaperIndicator`, mute toggle, user menu (logout)
- [ ] Nav: Home, Sports, Casino, Forum, Profile links
- [ ] Footer: mission statement, donation link placeholder
- [ ] `TaperIndicator` component — level badge + tooltip with full taper schedule
- [ ] Mute toggle component — state persisted in `localStorage`, consumed by all sound logic

### 1.6 Virtual Wallet

- [ ] `src/lib/wallet.ts` — `debitBalance` and `creditBalance` server helpers (write `transactions` row + update `users.virtual_balance`)
- [ ] Virtual balance shown in header, updates on bet placement and resolution
- [ ] Transaction history page (`/profile/transactions`)

### 1.7 Sports Betting

- [ ] Create `src/data/mock-matches.json` — 10–15 matches with team names, decimal odds, start times
- [ ] Sports page (`/sports`) — list mock matches with odds and a bet button per match
- [ ] `BetSlip` component — wager input, confirm button, shows potential payout
- [ ] Server action `placeBet` — validate balance, compute `resolves_at` via `resolveDelay(stimLevel)`, insert bet, debit balance
- [ ] Server-side cooldown check in `placeBet` — reject if another sports bet was placed within the cooldown window
- [ ] `CooldownTimer` component — shows `HH:MM:SS` remaining, message "Take a break"
- [ ] Display `CooldownTimer` on sports page when betting is locked
- [ ] Edge Function `resolve-bets` — runs every minute, resolves pending bets past `resolves_at`, writes outcome, credits/debits balance
- [ ] `BetCard` component — shows game_type, amount, odds, status ("Pending" / "Won" / "Lost"), no color-coding for wins
- [ ] Active and recent bets list on sports page

### 1.8 Session & Mandatory Reflection

- [ ] Auto-create `sessions` row when user places their first bet (if no active session exists)
- [ ] "End Session" button in header — only visible when a session is active
- [ ] `ReflectionModal` component — full-screen overlay, no close button, textarea (min 10 chars), "Submit & Continue"
- [ ] Server action `endSession` — validate reflection text, set `sessions.ended_at`, set `users.taper_started_at` if first ever session
- [ ] Block leaving game routes mid-session — intercept navigation, show `ReflectionModal` instead

### 1.9 Profile Page

- [ ] Profile page (`/profile`) — display name (editable), current stimulus level + level name
- [ ] Taper schedule table with current level highlighted
- [ ] "Advance my level" button — server action to manually decrement `stimulus_level` by 1 (floor: 1)
- [ ] Days active counter (from `taper_started_at`)
- [ ] Link to transaction history

---

## Phase 2 — Casino Games

### 2.1 Slots

- [ ] `SlotsGame` component — reads `useStimLevel()`; Level 5: animated reel spin + win flash; Level 3: result after 3s pause; Level 2+: plain text result
- [ ] Sound logic: play spin/win sounds at Level 5–4, chime at Level 3, silent at Level 2–1
- [ ] Server action `placeCasinoBet` — same balance + cooldown logic as `placeBet`, `game_type = 'slots'`
- [ ] 1h per-game cooldown enforced server-side for casino bets
- [ ] `CooldownTimer` on casino pages when locked
- [ ] Slots page (`/casino/slots`)

### 2.2 Roulette / Dice

- [ ] `RouletteGame` component — single number or color bet; result delay and animation follow level table via `useStimLevel()`
- [ ] Roulette page (`/casino/roulette`)
- [ ] Casino landing page (`/casino`) — list available games with descriptions

### 2.3 Audit

- [ ] Run `/stim-audit` — verify both casino components use `StimLevelContext` with no hard-coded level values

---

## Phase 3 — Community Forum

### 3.1 Posts

- [ ] Forum listing page (`/forum`) — all posts, title + author + date + reply count
- [ ] New post page (`/forum/new`) — title + body form
- [ ] Server action `createPost`
- [ ] Post detail page (`/forum/[postId]`) — post content + replies

### 3.2 Replies

- [ ] `ReplyForm` component on post detail page
- [ ] Server action `createReply`
- [ ] Replies displayed chronologically (flat thread), no engagement metrics

### 3.3 Moderation

- [ ] Report button on posts and replies → server action `reportContent` (inserts to a `reports` table)
- [ ] Soft delete: `is_deleted = true` replaces content with "[removed]"
- [ ] Post count badge on profile page (recovery stimulus)

---

## Phase 4 — Recovery Stimulus & Dashboard

### 4.1 Milestones

- [ ] `src/lib/milestones.ts` — `checkAndAwardMilestones(userId)` called after `endSession` and `taper-advance`
- [ ] Milestone types: `first_reflection`, `7_days`, `30_days`, `reached_level_4`, `reached_level_3`, `reached_level_2`, `reached_level_1`
- [ ] `MilestoneToast` component — slides in from bottom, auto-dismisses after 4s, no sound
- [ ] Milestone badge collection displayed on Profile page

### 4.2 Streak Tracker

- [ ] Add `current_streak` (integer) and `longest_streak` (integer) to `users` migration
- [ ] Streak logic in `endSession`: increment if last session was yesterday, reset if gap > 1 day
- [ ] Streak display on Profile page and subtly in header

### 4.3 Personal Dashboard

- [ ] Dashboard page (`/dashboard`)
- [ ] Bets over time chart (Recharts or similar — lightweight)
- [ ] Win/loss rate summary card
- [ ] Reflection history list (past `reflection_text` values with dates)
- [ ] Taper progress visualization (level timeline)

### 4.4 Donation Page

- [ ] Donation page (`/donate`) — mission statement + external donation link
- [ ] Donation link added to footer
