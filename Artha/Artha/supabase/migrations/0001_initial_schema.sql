create extension if not exists pgcrypto;
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 display_name text, avatar_url text, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.items (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 type text not null check (type in ('note','bookmark','youtube','document','task')),
 title text not null default '' check (char_length(title) <= 500), description text check (description is null or char_length(description) <= 5000),
 url text, storage_path text, content jsonb not null default '{}'::jsonb, tags text[] not null default '{}',
 revision bigint not null default 0, created_at timestamptz not null default now(), updated_at timestamptz not null default now(), deleted_at timestamptz,
 constraint items_url_protocol check (url is null or url ~* '^https?://')
);
create index if not exists items_user_updated_idx on public.items(user_id, updated_at desc);
create index if not exists items_user_type_idx on public.items(user_id, type) where deleted_at is null;
create index if not exists items_tags_idx on public.items using gin(tags);
create table if not exists public.sync_state (
 user_id uuid not null references auth.users(id) on delete cascade, device_id text not null, cursor timestamptz,
 last_success_at timestamptz, updated_at timestamptz not null default now(), primary key(user_id, device_id)
);
alter table public.profiles enable row level security;
alter table public.items enable row level security;
alter table public.sync_state enable row level security;
create policy "profile select own" on public.profiles for select using (auth.uid() = id);
create policy "profile insert own" on public.profiles for insert with check (auth.uid() = id);
create policy "profile update own" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);
create policy "items select own" on public.items for select using (auth.uid() = user_id);
create policy "items insert own" on public.items for insert with check (auth.uid() = user_id);
create policy "items update own" on public.items for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "items delete own" on public.items for delete using (auth.uid() = user_id);
create policy "sync state select own" on public.sync_state for select using (auth.uid() = user_id);
create policy "sync state insert own" on public.sync_state for insert with check (auth.uid() = user_id);
create policy "sync state update own" on public.sync_state for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values ('user-files','user-files',false,52428800,array['application/pdf','application/epub+zip','text/plain','image/png','image/jpeg']) on conflict(id) do nothing;
create policy "user files read own" on storage.objects for select to authenticated using(bucket_id='user-files' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "user files insert own" on storage.objects for insert to authenticated with check(bucket_id='user-files' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "user files update own" on storage.objects for update to authenticated using(bucket_id='user-files' and (storage.foldername(name))[1]=auth.uid()::text) with check(bucket_id='user-files' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "user files delete own" on storage.objects for delete to authenticated using(bucket_id='user-files' and (storage.foldername(name))[1]=auth.uid()::text);
