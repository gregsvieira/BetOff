-- Peer-support forum: flat replies under each post, soft delete only, no
-- engagement metrics. Any authenticated user can read every non-deleted thread.

create table if not exists public.forum_posts (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.users (id) on delete cascade,
  title      text not null,
  body       text not null,
  created_at timestamptz not null default now(),
  is_deleted boolean not null default false
);

create table if not exists public.forum_replies (
  id         uuid primary key default gen_random_uuid(),
  post_id    uuid not null references public.forum_posts (id) on delete cascade,
  user_id    uuid not null references public.users (id) on delete cascade,
  body       text not null,
  created_at timestamptz not null default now(),
  is_deleted boolean not null default false
);

create index if not exists forum_posts_created_at_idx on public.forum_posts (created_at desc);
create index if not exists forum_replies_post_id_idx on public.forum_replies (post_id, created_at);

alter table public.forum_posts enable row level security;
alter table public.forum_replies enable row level security;

drop policy if exists "Authenticated users can read posts" on public.forum_posts;
create policy "Authenticated users can read posts"
  on public.forum_posts for select
  to authenticated
  using (true);

drop policy if exists "Users can create own posts" on public.forum_posts;
create policy "Users can create own posts"
  on public.forum_posts for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can edit own posts" on public.forum_posts;
create policy "Users can edit own posts"
  on public.forum_posts for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

drop policy if exists "Authenticated users can read replies" on public.forum_replies;
create policy "Authenticated users can read replies"
  on public.forum_replies for select
  to authenticated
  using (true);

drop policy if exists "Users can create own replies" on public.forum_replies;
create policy "Users can create own replies"
  on public.forum_replies for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

drop policy if exists "Users can edit own replies" on public.forum_replies;
create policy "Users can edit own replies"
  on public.forum_replies for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);
