-- Gulls Gallery: allow one painting to have multiple photos.
-- Run this once in Supabase Dashboard -> SQL Editor.
alter table public.paintings
add column if not exists image_paths text[] not null default '{}';

-- Keep existing cover images available in the gallery array.
update public.paintings
set image_paths = array[image_path]
where image_path is not null
  and (image_paths is null or cardinality(image_paths) = 0);
