-- Gulls Gallery: create the sets table.
-- Run this in Supabase Dashboard -> SQL Editor.
create table if not exists public.painting_sets (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  price numeric(12,2) not null check (price >= 0),
  currency text not null default 'PKR',
  image_paths text[] not null default '{}',
  status text not null default 'available',
  created_at timestamptz not null default now()
);

alter table public.painting_sets enable row level security;

-- Visitors can view sets that are currently available.
drop policy if exists "Public can view available painting sets" on public.painting_sets;
create policy "Public can view available painting sets"
on public.painting_sets for select
to anon, authenticated
using (status = 'available');

-- Only the configured admin account can create, edit, or delete sets.
drop policy if exists "Admin can manage painting sets" on public.painting_sets;
create policy "Admin can manage painting sets"
on public.painting_sets for all
to authenticated
using (auth.uid() = '400db0ba-94ab-4242-bbef-058128b2f06e'::uuid)
with check (auth.uid() = '400db0ba-94ab-4242-bbef-058128b2f06e'::uuid);
