-- Gulls Gallery: limit identical review text to 3 submissions per artwork.
-- Run this once in Supabase Dashboard -> SQL Editor.

create or replace function public.limit_duplicate_artwork_reviews()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  normalized_text text;
  matching_count integer;
  lock_key bigint;
begin
  normalized_text := lower(regexp_replace(trim(new.review_text), '\s+', ' ', 'g'));
  lock_key := hashtextextended(
    new.artwork_kind || ':' || new.artwork_id::text || ':' || normalized_text,
    0
  );

  -- Serialize identical submissions so simultaneous requests cannot exceed the limit.
  perform pg_advisory_xact_lock(lock_key);

  select count(*)::integer
    into matching_count
  from public.artwork_reviews r
  where r.artwork_id = new.artwork_id
    and r.artwork_kind = new.artwork_kind
    and lower(regexp_replace(trim(r.review_text), '\s+', ' ', 'g')) = normalized_text;

  if matching_count >= 3 then
    raise exception 'This same comment has already been submitted 3 times for this artwork.'
      using errcode = '23514';
  end if;

  return new;
end;
$$;

drop trigger if exists limit_duplicate_artwork_reviews_trigger on public.artwork_reviews;

create trigger limit_duplicate_artwork_reviews_trigger
before insert on public.artwork_reviews
for each row
execute function public.limit_duplicate_artwork_reviews();
