-- A session is a period of active play. It opens on the first bet and can only
-- be closed with a reflection of at least 10 characters (mandatory reflection).

create table if not exists public.sessions (
  id                        uuid primary key default gen_random_uuid(),
  user_id                   uuid not null references public.users (id) on delete cascade,
  started_at                timestamptz not null default now(),
  ended_at                  timestamptz,
  reflection_text           text,
  stimulus_level_at_session integer not null check (stimulus_level_at_session between 1 and 5),
  constraint sessions_reflection_required_on_end
    check (
      ended_at is null
      or (reflection_text is not null and char_length(reflection_text) >= 10)
    )
);

create index if not exists sessions_user_id_idx on public.sessions (user_id);

-- At most one open session per user.
create unique index if not exists sessions_one_active_per_user
  on public.sessions (user_id) where ended_at is null;

alter table public.sessions enable row level security;

drop policy if exists "Users can view own sessions" on public.sessions;
create policy "Users can view own sessions"
  on public.sessions for select
  using ((select auth.uid()) = user_id);

drop policy if exists "Users can open own sessions" on public.sessions;
create policy "Users can open own sessions"
  on public.sessions for insert
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can end own sessions" on public.sessions;
create policy "Users can end own sessions"
  on public.sessions for update
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
