-- Recovery-stimulus awards (streaks, days active, level reached). Awarded by
-- server logic after endSession and the taper-advance cron.

create table if not exists public.milestones (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.users (id) on delete cascade,
  type        text not null,
  achieved_at timestamptz not null default now(),
  constraint milestones_unique_per_user unique (user_id, type)
);

create index if not exists milestones_user_id_idx on public.milestones (user_id);

alter table public.milestones enable row level security;

drop policy if exists "Users can view own milestones" on public.milestones;
create policy "Users can view own milestones"
  on public.milestones for select
  using ((select auth.uid()) = user_id);

-- Awarded from server actions running under the user's JWT (endSession);
-- the taper-advance cron writes with the service role and bypasses RLS.
drop policy if exists "Users can earn own milestones" on public.milestones;
create policy "Users can earn own milestones"
  on public.milestones for insert
  with check ((select auth.uid()) = user_id);
