-- Gia Phả Tổ Tiên — Supabase setup
-- Run this whole file in Supabase Dashboard > SQL Editor > New query.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('admin','member')),
  display_name text,
  created_at timestamptz not null default now()
);

create table if not exists public.family_members (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  gender text,
  generation integer not null default 1 check (generation > 0),
  birth_year text,
  death_year text,
  parent_id uuid references public.family_members(id) on delete set null,
  hometown text,
  bio text,
  photo_url text, -- legacy/optional URL field
  photo_path text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists family_members_generation_idx on public.family_members(generation);
create index if not exists family_members_name_idx on public.family_members(full_name);
create index if not exists family_members_parent_idx on public.family_members(parent_id);

alter table public.profiles enable row level security;
alter table public.family_members enable row level security;

drop policy if exists "Authenticated users can read profiles" on public.profiles;
create policy "Authenticated users can read profiles"
on public.profiles for select to authenticated using (true);

drop policy if exists "Users can read family members" on public.family_members;
create policy "Users can read family members"
on public.family_members for select to authenticated using (true);

drop policy if exists "Admins can insert family members" on public.family_members;
create policy "Admins can insert family members"
on public.family_members for insert to authenticated
with check (exists (select 1 from public.profiles p where p.user_id = (select auth.uid()) and p.role = 'admin'));

drop policy if exists "Admins can update family members" on public.family_members;
create policy "Admins can update family members"
on public.family_members for update to authenticated
using (exists (select 1 from public.profiles p where p.user_id = (select auth.uid()) and p.role = 'admin'))
with check (exists (select 1 from public.profiles p where p.user_id = (select auth.uid()) and p.role = 'admin'));

drop policy if exists "Admins can delete family members" on public.family_members;
create policy "Admins can delete family members"
on public.family_members for delete to authenticated
using (exists (select 1 from public.profiles p where p.user_id = (select auth.uid()) and p.role = 'admin'));

-- Private family portrait bucket; access is limited to signed-in users.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('ancestor-portraits', 'ancestor-portraits', false, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public = false, file_size_limit = 5242880, allowed_mime_types = array['image/jpeg','image/png','image/webp'];

drop policy if exists "Members can view ancestor portraits" on storage.objects;
create policy "Members can view ancestor portraits"
on storage.objects for select to authenticated
using (bucket_id = 'ancestor-portraits');

drop policy if exists "Admins can upload ancestor portraits" on storage.objects;
create policy "Admins can upload ancestor portraits"
on storage.objects for insert to authenticated
with check (bucket_id = 'ancestor-portraits' and exists (select 1 from public.profiles p where p.user_id = (select auth.uid()) and p.role = 'admin'));

drop policy if exists "Admins can update ancestor portraits" on storage.objects;
create policy "Admins can update ancestor portraits"
on storage.objects for update to authenticated
using (bucket_id = 'ancestor-portraits' and exists (select 1 from public.profiles p where p.user_id = (select auth.uid()) and p.role = 'admin'))
with check (bucket_id = 'ancestor-portraits' and exists (select 1 from public.profiles p where p.user_id = (select auth.uid()) and p.role = 'admin'));

drop policy if exists "Admins can delete ancestor portraits" on storage.objects;
create policy "Admins can delete ancestor portraits"
on storage.objects for delete to authenticated
using (bucket_id = 'ancestor-portraits' and exists (select 1 from public.profiles p where p.user_id = (select auth.uid()) and p.role = 'admin'));

-- After creating your first user in Supabase Authentication > Users,
-- replace the email below with the exact email and run this statement separately:
-- insert into public.profiles (user_id, role, display_name)
-- select id, 'admin', 'Quản trị gia phả' from auth.users where email = 'YOUR_ADMIN_EMAIL'
-- on conflict (user_id) do update set role = 'admin';

-- IMPORTANT: keep family data private. This schema requires login to read family data.

-- Safe to run on an existing project too:
alter table public.family_members add column if not exists photo_path text;
