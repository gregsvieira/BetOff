# BetOff — Implementation Plan

## Architecture

| Layer | Technology |
|-------|-----------|
| Frontend | Next.js 14 (App Router), TypeScript, Tailwind CSS |
| Backend / DB | Supabase (PostgreSQL, Auth, Edge Functions) |
| Hosting | Vercel (frontend), Supabase Cloud (backend) |
| Odds data | The Odds API (free tier) — Phase 1 may use static mock data |

**Rendering strategy:**
- Public pages (home, about, forum browse): Server Components, SSR.
- Interactive game UIs (slots, roulette, bet placement): Client Components, minimal state.
- Auth pages: Next.js middleware + Supabase Auth helpers.

---

## Stimulus Taper System

The taper is the central design pattern. Every game component and design token is driven by the user's current `stimulus_level` (1–5).

| Level | Name | Trigger | Sounds | Animations | Color palette | Result delay |
|-------|------|---------|--------|-----------|---------------|-------------|
| 5 | **Rush** | Days 0–7 | Full volume, win jingles, spin sounds | Full: reels spin, win flash, confetti | Vibrant: gold + crimson, dark bg | 30 seconds |
| 4 | **High** | Days 8–21 | 60% volume, reduced variety | Slower spins, no confetti | Slightly muted: warm amber tones | 5 minutes |
| 3 | **Medium** | Days 22–60 | 25% volume, subtle only | Fade transitions only | Muted: desaturated warm | 30 minutes |
| 2 | **Low** | Days 61–120 | Off | No game animations | Calm: slate + sage green | 4 hours |
| 1 | **Minimal** | Day 121+ | Off | None | Full BetOff calm palette | 24 hours |

**Advancement rules:**
- Level decreases automatically based on days since `taper_started_at` (set on first completed session).
- Users can voluntarily advance to a lower level from Profile settings — never forced back.
- The taper schedule and current level are always visible on the Profile page (transparent).

**Technical propagation:**
- `stimulus_level` is read from the user profile on page load.
- Injected as a CSS custom property (`--stim-level: 5`) on `<html>` and as a React context value (`StimLevelContext`).
- All game components and Tailwind design tokens read from this single source — no hardcoded level checks scattered in component code.

---

## Data Model

### `users` (extends Supabase auth.users)
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | FK to auth.users |
| display_name | text | Anonymous username |
| virtual_balance | integer | In virtual coins; default 1000 |
| stimulus_level | integer | 1–5; default 5 |
| taper_started_at | timestamptz | Set on first completed session |
| created_at | timestamptz | |

### `bets`
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | |
| user_id | uuid | FK users |
| game_type | enum | sports \| slots \| roulette |
| amount | integer | Virtual coins wagered |
| odds | jsonb | Snapshot of odds at placement |
| outcome | enum | win \| loss \| void — null until resolved |
| status | enum | pending \| resolved |
| placed_at | timestamptz | |
| resolves_at | timestamptz | Computed from stimulus_level at placement time |
| resolved_at | timestamptz | Actual resolution time |

### `sessions`
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | |
| user_id | uuid | FK users |
| started_at | timestamptz | |
| ended_at | timestamptz | Null if active |
| reflection_text | text | Required before ended_at is set |
| stimulus_level_at_session | integer | Snapshot of level for analytics |

### `milestones`
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | |
| user_id | uuid | FK users |
| type | text | e.g. "7_days", "first_reflection", "reached_level_3" |
| achieved_at | timestamptz | |

### `forum_posts`
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | |
| user_id | uuid | FK users |
| title | text | |
| body | text | |
| created_at | timestamptz | |
| is_deleted | boolean | Soft delete |

### `forum_replies`
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | |
| post_id | uuid | FK forum_posts |
| user_id | uuid | FK users |
| body | text | |
| created_at | timestamptz | |
| is_deleted | boolean | Soft delete |

### `transactions`
| Column | Type | Notes |
|--------|------|-------|
| id | uuid | |
| user_id | uuid | FK users |
| delta | integer | Positive = gain, negative = loss |
| reason | text | e.g. "bet_win", "bet_loss", "signup_bonus" |
| created_at | timestamptz | |

---

## Feature Phases

### Phase 0 — Spec & Design *(current)*
- [x] `docs/context.md`
- [x] `docs/plan.md`
- [x] `docs/design-system.md`

### Phase 1 — MVP (Auth + Sports Betting + Reflection) at Level 5
**Goal:** A user can sign up, place a virtual sports bet at full stimulus (Level 5), wait for resolution, and complete a reflection prompt.

- Auth: email/password sign-up and login via Supabase Auth.
- Virtual wallet: 1000 coin starting balance, displayed in header.
- Sports betting: list of upcoming matches with mocked odds; place a single bet per match; `resolves_at` = `placed_at + 30s` (Level 5 delay); resolved by a Supabase Edge Function (runs every minute in MVP).
- Session tracking: session starts on first bet action, ends when user clicks "End Session."
- Mandatory reflection: "End Session" triggers a modal with a journaling prompt. Submission required (minimum 10 characters). Sets `taper_started_at` on first submission.
- Taper indicator: persistent badge in header showing "Level 5 — Rush" with a tooltip explaining the taper schedule.
- Profile page: taper schedule table, current level, option to advance voluntarily.
- Full Level 5 experience: win jingles, confetti on win, spin animations, vibrant gold/crimson palette.
- Basic layout: header, nav (Home, Sports, Casino, Forum, Profile), footer.

### Phase 2 — Casino Games (stimulus_level-aware)
**Goal:** Add slots and roulette; all game components read from StimLevelContext.

- **Slots**: 3-reel display. At Level 5: animated spin + win flash. At Level 3+: result appears after a plain pause. No sound at Level 2+.
- **Roulette/Dice**: single number or color bet. Result delay and animation follow level table.
- Per-game cooldown: 1h between casino game sessions (separate from sports cooldown). Enforced server-side.
- All games share the same virtual balance, session, and reflection system.

### Phase 3 — Community Forum
**Goal:** Peer support space for users to share experiences.

- Threaded posts: any authenticated user can create a post (title + body).
- Replies: flat thread under each post.
- User display names (no real names).
- Report button on posts and replies (logged to DB for admin review).
- No upvoting, no engagement metrics displayed.
- Forum recognition: post count badge visible on user's profile (recovery stimulus).

### Phase 4 — Recovery Stimulus & Dashboard
**Goal:** As gambling stimulus decreases, recovery rewards fill the gap.

- **Milestones**: awarded automatically ("7 days on BetOff", "First reflection", "Reached Level 3"). Displayed on Profile as a badge collection.
- **Streak tracker**: consecutive days with a completed session + reflection. Resets if missed.
- **Personal dashboard**: chart of bets over time, win/loss rate, reflection history, taper progress.
- **Donation page**: link to Open Collective or similar; brief mission statement.

---

## Key Technical Decisions

### Stimulus Level Propagation
`stimulus_level` is the single source of truth. On page load, the Next.js layout reads it from Supabase, sets `<html data-stim="5">` and wraps children in `<StimLevelProvider>`. Tailwind variants keyed on `data-stim` control colors, animation classes, and transition durations. Game components consume `useStimLevel()` for sound and animation logic.

### Bet Resolution
A Supabase Edge Function runs on a schedule (every minute for Level 5; every 15 min otherwise). It queries `bets` where `status = 'pending'` and `resolves_at <= now()`, computes outcome (mocked in Phase 1, real API in Phase 2+), sets `outcome` and `status = 'resolved'`, and updates `virtual_balance` via `INSERT` into `transactions`.

### resolves_at Computation
At bet placement, the server computes `resolves_at` based on `stimulus_level` at that moment:
- Level 5 → `placed_at + 30s`
- Level 4 → `placed_at + 5m`
- Level 3 → `placed_at + 30m`
- Level 2 → `placed_at + 4h`
- Level 1 → `placed_at + 24h`

The snapshot is stored on the bet — a level change after placement does not retroactively change pending bets.

### Taper Advancement (server-side cron)
A Supabase Edge Function runs daily. For each user where `taper_started_at IS NOT NULL`, it computes `days_active = now() - taper_started_at` and updates `stimulus_level` to the correct tier if the current level is higher than the tier the user has earned. Never increases level.

### Odds Data
Phase 1: static JSON file with 10–15 mocked matches. Phase 2+: The Odds API free tier (500 req/month), cached in Supabase with a 1h TTL.

### No Realtime in MVP
Forum posts and bet status updates are fetched on page load or manual refresh. Supabase Realtime is deferred to Phase 3+.
