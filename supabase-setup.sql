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


-- ---------------------------------------------------------------------------
-- Short share links.  One row per "Copy link", keyed by a 7-character id, so a
-- shared note travels as  myscribbly.vercel.app/#s=k3Rt9wQ  instead of the
-- whole note base64'd into the address bar.
--
-- Anyone may create a share and anyone holding the id may read it — that IS the
-- sharing model, same as an unlisted link. There is deliberately no update or
-- delete policy, so a published link can never be rewritten under someone else.
create table if not exists public.shares (
  id         text primary key,
  name       text        not null default 'Shared note',
  content    text        not null default '',
  images     jsonb       not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  -- an id is exactly what the app generates; nothing else gets a row
  constraint shares_id_shape check (id ~ '^[0-9A-Za-z]{7,16}$'),
  -- a note is text: 400 KB is a very long one, and caps abuse of the open insert
  constraint shares_content_size check (length(content) <= 400000),
  constraint shares_name_size    check (length(name)    <= 200)
);

alter table public.shares enable row level security;

drop policy if exists "read a share by id" on public.shares;
create policy "read a share by id"
  on public.shares for select to anon, authenticated using (true);

drop policy if exists "create a share" on public.shares;
create policy "create a share"
  on public.shares for insert to anon, authenticated with check (true);
