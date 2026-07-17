-- Scribbly cloud sync — run this ONCE in your Supabase project.
-- Dashboard → SQL Editor → New query → paste all of this → Run.
--
-- It creates one row per user holding their whole workspace, and locks it down
-- so each signed-in user can only read/write THEIR OWN row (Row-Level Security).

create table if not exists public.workspaces (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  data       jsonb        not null default '{}'::jsonb,
  updated_at timestamptz  not null default now()
);

alter table public.workspaces enable row level security;

-- One policy: you may do anything, but only to the row whose user_id is you.
drop policy if exists "own workspace" on public.workspaces;
create policy "own workspace"
  on public.workspaces
  for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
