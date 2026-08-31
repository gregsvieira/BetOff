-- public.users extends auth.users with BetOff profile + taper state.
-- The taper is driven entirely by stimulus_level (1 = calm, 5 = full stimulus).

create table if not exists public.users (
  id               uuid primary key references auth.users (id) on delete cascade,
  display_name     text not null,
  virtual_balance  integer not null default 1000,
  stimulus_level   integer not null default 5 check (stimulus_level between 1 and 5),
  taper_started_at timestamptz,
  created_at       timestamptz not null default now()
);

alter table public.users enable row level security;

drop policy if exists "Users can view own profile" on public.users;
create policy "Users can view own profile"
  on public.users for select
  using ((select auth.uid()) = id);

drop policy if exists "Users can update own profile" on public.users;
create policy "Users can update own profile"
  on public.users for update
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);
