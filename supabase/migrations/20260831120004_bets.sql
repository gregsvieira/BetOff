-- Every wager across sports + casino. resolves_at is a snapshot computed from
-- the user's stimulus_level at placement time; later level changes do not move it.

create table if not exists public.bets (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.users (id) on delete cascade,
  game_type   public.game_type not null,
  amount      integer not null check (amount > 0),
  odds        jsonb not null,
  outcome     public.bet_outcome,
  status      public.bet_status not null default 'pending',
  placed_at   timestamptz not null default now(),
  resolves_at timestamptz not null,
  resolved_at timestamptz,
  constraint bets_resolved_has_outcome
    check (status = 'pending' or outcome is not null)
);

create index if not exists bets_user_id_idx on public.bets (user_id);
create index if not exists bets_pending_resolves_at_idx
  on public.bets (resolves_at) where status = 'pending';

alter table public.bets enable row level security;

-- Users read + place their own bets. Resolution is done by the resolve-bets
-- Edge Function using the service role, which bypasses RLS.
drop policy if exists "Users can view own bets" on public.bets;
create policy "Users can view own bets"
  on public.bets for select
  using ((select auth.uid()) = user_id);

drop policy if exists "Users can place own bets" on public.bets;
create policy "Users can place own bets"
  on public.bets for insert
  with check ((select auth.uid()) = user_id);
