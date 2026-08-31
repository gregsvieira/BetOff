-- Append-only ledger of every virtual-coin movement. users.virtual_balance is
-- the running total; this table is the audit trail behind it.

create table if not exists public.transactions (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.users (id) on delete cascade,
  delta      integer not null,
  reason     text not null,
  created_at timestamptz not null default now()
);

create index if not exists transactions_user_id_created_at_idx
  on public.transactions (user_id, created_at desc);

alter table public.transactions enable row level security;

-- Read-only to the owner. Rows are written by server-side wallet helpers.
drop policy if exists "Users can view own transactions" on public.transactions;
create policy "Users can view own transactions"
  on public.transactions for select
  using ((select auth.uid()) = user_id);

drop policy if exists "Users can record own transactions" on public.transactions;
create policy "Users can record own transactions"
  on public.transactions for insert
  with check ((select auth.uid()) = user_id);
