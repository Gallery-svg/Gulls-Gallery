-- Gulls Gallery: customer reviews with admin approval.
-- Run this once in Supabase Dashboard -> SQL Editor.
create table if not exists public.artwork_reviews (
  id uuid primary key default gen_random_uuid(),
  artwork_id uuid not null,
  artwork_kind text not null check (artwork_kind in ('painting','set')),
  reviewer_name text not null default 'Guest',
  rating integer not null check (rating between 1 and 5),
  review_text text not null check (char_length(trim(review_text)) between 5 and 1200),
  is_published boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.artwork_reviews enable row level security;

drop policy if exists "Public can read approved artwork reviews" on public.artwork_reviews;
create policy "Public can read approved artwork reviews"
on public.artwork_reviews for select
to anon, authenticated
using (is_published = true);

drop policy if exists "Visitors can submit pending artwork reviews" on public.artwork_reviews;
create policy "Visitors can submit pending artwork reviews"
on public.artwork_reviews for insert
to anon, authenticated
with check (is_published = false);

drop policy if exists "Gallery admin can read all artwork reviews" on public.artwork_reviews;
create policy "Gallery admin can read all artwork reviews"
on public.artwork_reviews for select
to authenticated
using (auth.uid() = '400db0ba-94ab-4242-bbef-058128b2f06e'::uuid);

drop policy if exists "Gallery admin can update artwork reviews" on public.artwork_reviews;
create policy "Gallery admin can update artwork reviews"
on public.artwork_reviews for update
to authenticated
using (auth.uid() = '400db0ba-94ab-4242-bbef-058128b2f06e'::uuid)
with check (auth.uid() = '400db0ba-94ab-4242-bbef-058128b2f06e'::uuid);

drop policy if exists "Gallery admin can delete artwork reviews" on public.artwork_reviews;
create policy "Gallery admin can delete artwork reviews"
on public.artwork_reviews for delete
to authenticated
using (auth.uid() = '400db0ba-94ab-4242-bbef-058128b2f06e'::uuid);
