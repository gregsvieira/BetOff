# BetOff — Design System

## Philosophy

The platform is as stimulating as the user needs it to be right now, and gradually less so over time. Every visual and interaction parameter is keyed to the user's current stimulus level (1–5). Level 5 competes with real gambling platforms on excitement. Level 1 is calm, minimal, and restorative.

Implementation: the `<html>` element carries a `data-stim="N"` attribute. Tailwind CSS variants and CSS custom properties key off this attribute. No component should hard-code a level check — all stimulus-driven styles flow from this single source.

---

## Color Palettes (per level)

### Level 5 — Rush
| Token | Value | Usage |
|-------|-------|-------|
| `bg-base` | `#1A1209` | Dark warm background |
| `bg-surface` | `#2A1E0E` | Cards, modals |
| `accent` | `#C9A03E` | Rich gold — primary action |
| `accent-win` | `#E8C45A` | Win state highlight |
| `highlight` | `#B03030` | Crimson — secondary accent |
| `text-primary` | `#F5E9CC` | Warm cream |
| `text-secondary` | `#A89070` | Muted gold |

### Level 4 — High
| Token | Value | Usage |
|-------|-------|-------|
| `bg-base` | `#1F1710` | Slightly lighter dark |
| `accent` | `#B8893A` | Amber |
| `highlight` | `#8C3030` | Muted crimson |
| `text-primary` | `#EDE0C4` | |

### Level 3 — Medium
| Token | Value | Usage |
|-------|-------|-------|
| `bg-base` | `#2A2520` | Dark warm slate |
| `accent` | `#8A7050` | Desaturated amber |
| `highlight` | `#6B4040` | Very muted red |
| `text-primary` | `#D4C9B8` | |

### Level 2 — Low
| Token | Value | Usage |
|-------|-------|-------|
| `bg-base` | `#F0F0ED` | Light warm gray |
| `bg-surface` | `#FFFFFF` | |
| `accent` | `#4A7C59` | Sage green |
| `text-primary` | `#2A2A2A` | |
| `text-secondary` | `#6B6B6B` | |

### Level 1 — Minimal
| Token | Value | Usage |
|-------|-------|-------|
| `bg-base` | `#F7F7F5` | Warm white |
| `bg-surface` | `#FFFFFF` | |
| `bg-muted` | `#EEEDE9` | |
| `accent` | `#4A7C59` | Sage green |
| `accent-hover` | `#3A6347` | |
| `border` | `#D9D8D4` | |
| `text-primary` | `#1A1A1A` | |
| `text-secondary` | `#6B6B6B` | |
| `error` | `#B85C5C` | |

---

## Typography

Typography is level-independent — consistency aids readability at all stages.

- **Font**: Inter (system fallback: `-apple-system, sans-serif`)
- **Base size**: 16px
- **Scale**: 12 / 14 / 16 / 18 / 24 / 32px
- **Line height**: 1.6 for body, 1.2 for headings

| Role | Size | Weight |
|------|------|--------|
| Heading 1 | 32px | 600 |
| Heading 2 | 24px | 600 |
| Body | 16px | 400 |
| Label | 14px | 500 |
| Caption | 12px | 400 |

---

## Motion Policy (per level)

| Level | Game outcome animations | UI transitions | Looping effects |
|-------|------------------------|---------------|-----------------|
| 5 | Full: reel spin, win flash, confetti burst | 300ms ease-in-out | Subtle ambient glow on active bet |
| 4 | Slower spin (no confetti), win highlight | 200ms ease-in-out | None |
| 3 | Fade reveal only (no spin), no win highlight | 150ms ease-in-out | None |
| 2 | No animations — result appears instantly as text | 100ms ease | None |
| 1 | No animations | 100ms ease | None |

---

## Sound Policy (per level)

| Level | Win jingle | Spin / roll sound | Ambient |
|-------|-----------|------------------|---------|
| 5 | Yes, full volume | Yes, full | Optional subtle background |
| 4 | Yes, 60% volume | Yes, 60% | None |
| 3 | Subtle chime, 25% | None | None |
| 2 | None | None | None |
| 1 | None | None | None |

All sounds must be loaded lazily and only after explicit user interaction (browser autoplay policy). A global mute toggle is always accessible in the header, at any level.

---

## Component Guidelines

### TaperIndicator
Persistent in the header. Shows "Level 5 · Rush" with a progress bar indicating how far the user is toward Level 1. On hover/tap: a tooltip shows the full taper schedule and days remaining at current level. Styled to feel like a progress tracker, not a warning. Never shows countdown anxiety ("only X days left at this level").

### BetCard
Displays a single pending or resolved bet. At Level 5: card uses the gold/dark palette with a glowing border on pending bets. At Level 2–1: flat card, `bg-surface`, `border`, text-only status badge ("Pending", "Won", "Lost") with no color differentiation for wins.

### GameOutcome
The component that reveals bet results. At Level 5: animated reveal sequence (spin, flash, result). At Level 3: 2-second fade-in. At Level 2–1: plain text, no transition beyond the default 100ms. This component reads from `StimLevelContext` — no level-specific logic elsewhere.

### CooldownTimer
Always visible when a game type is in cooldown. Displays remaining time in `HH:MM:SS`. Styled in `text-secondary`. Message: "Your next bet is available in [time]." No urgency framing.

### ReflectionModal
Full-screen overlay. No close (×) button at any level. Single `<textarea>` with a prompt and "Submit & Continue." Minimum 10 characters to submit. Background: `bg-base` for current level — at Level 5 this is the dark warm palette; at Level 1 it is the calm warm white.

### MilestoneToast
A non-intrusive notification that appears when a milestone is earned ("7 days on BetOff 🎯"). Slides in from the bottom, auto-dismisses after 4 seconds. No sound. Styled in the current level's accent color. The only place recovery achievements surface proactively.

### Forum Post
Plain layout at all levels: title (Heading 2), author display name + date (Caption), body (Body). No upvote count, no share buttons, no engagement metrics.

---

## Iconography

- Lucide Icons (minimal, consistent line weight).
- No gambling iconography in UI chrome (no playing cards, dice, slot symbols, poker chips).
- Game pages may use contextual icons (e.g. a roulette wheel icon as a page header illustration), but these must be static — no spinning or animated icons.

---

## Accessibility

- WCAG AA contrast minimum at every stimulus level (Level 5 dark palette included).
- All interactive elements keyboard-navigable.
- Sound is always opt-in (never autoplay without prior interaction).
- Mute toggle visible in header at all times.
- TaperIndicator tooltip accessible via keyboard focus.
