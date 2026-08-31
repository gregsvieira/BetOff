-- Core domain enums for BetOff.
-- CREATE TYPE has no IF NOT EXISTS guard, so wrap each in a DO block that
-- swallows duplicate_object, keeping the migration safe to re-run in dev.

do $$ begin
  create type public.game_type as enum ('sports', 'slots', 'roulette');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.bet_outcome as enum ('win', 'loss', 'void');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.bet_status as enum ('pending', 'resolved');
exception when duplicate_object then null;
end $$;
