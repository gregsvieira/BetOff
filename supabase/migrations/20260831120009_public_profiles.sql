-- users RLS restricts each row to its owner, but the forum needs to show every
-- author's display name. This view exposes only the non-sensitive columns
-- (never virtual_balance / stimulus_level) to any authenticated user.

create or replace view public.profiles
with (security_invoker = off) as
  select id, display_name
  from public.users;

revoke all on public.profiles from anon, authenticated;
grant select on public.profiles to authenticated;
